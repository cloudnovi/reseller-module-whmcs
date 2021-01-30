<?php
/**
 * Dashflo Reseller
 *
 * Resell Dashflo services to your customers
 *
 * @package    Dashflo Reseller Module for WHMCS
 * @author     Dashflo Ltd <support@dashflo.net>
 * @copyright  2018-2021 Dashflo Ltd
 * @version:   2.0.1
 * @link       https://dashflo.net/reseller
 */

if (!defined("WHMCS")) {
    die("This file cannot be accessed directly");
}

require_once __DIR__ . "/lib/http.php";

require_once __DIR__ . "/logic/databases.php";
require_once __DIR__ . "/logic/power.php";
require_once __DIR__ . "/logic/reinstall.php";

use WHMCS\Database\Capsule;

/**
 * Define module related meta data.
 *
 * @return array
 */
function dashflo_MetaData()
{
    return [
        "DisplayName" => "Dashflo Reseller",
        "RequiresServer" => false,
    ];
}

/**
 * Define product configuration options.
 *
 * @return array
 */
function dashflo_ConfigOptions($params)
{
    return [
        "plan" => [
            "FriendlyName" => "Plan",
            "Type" => "dropdown",
            "Options" => [
                "117" => "Minecraft - 1GB",
                "118" => "Minecraft - 2GB",
                "119" => "Minecraft - 4GB",
                "120" => "Minecraft - 6GB",
                "121" => "Minecraft - 8GB",
                "127" => "VPS - 2GB",
                "128" => "VPS - 4GB",
                "129" => "VPS - 8GB",
                "130" => "VPS - 12GB",
                "131" => "VPS - 16GB",
                "68" => "Baremetal - Intel",
                "2" => "Baremetal - Ryzen",
            ],
            "Description" => "The plan to automatically order",
            "Default" => "117",
        ],
        "billing_cycle" => [
            "FriendlyName" => "Billing Cycle",
            "Type" => "dropdown",
            "Options" => [
                "monthly" => "Monthly",
                "quarterly" => "Quarterly",
                "semi-annually" => "Semi-Annually",
                "annually" => "Annually",
            ],
            "Description" => "The billing cycle for the ordered service",
            "Default" => "monthly",
        ],
    ];
}

/**
 * Gets the Dashflo service ID
 *
 * @param array $params common module parameters
 *
 * @return integer dashflo service id
 */
function dashflo_Id($params)
{
    $id = Capsule::table("tblhosting")
        ->where("id", $params["serviceid"])
        ->value("dedicatedip");

    return $id;
}

/**
 * Orders a service from Dashflo.
 *
 * Attempt to provision a new instance of a given product/service. This is
 * called any time provisioning is requested inside of WHMCS. Depending upon the
 * configuration, this can be any of:
 * * When a new order is placed
 * * When an invoice for a new order is paid
 * * Upon manual request by an admin user
 *
 * @param array $params common module parameters
 *
 * @return string "success" or an error message
 */
function dashflo_CreateAccount(array $params)
{
    if (dashflo_Id($params)) {
        return "Service already deployed";
    }

    $body = [
        "product" => $params["configoption1"],
        "billing_cycle" => $params["configoption2"] ?: "monthly",
        "email_order" => true,
        "email_invoice" => false,
        "config_options" => $params["configoptions"],
        "custom_fields" => $params["customfields"],
    ];

    $deploy = dashflo_Api("POST", "/store/order", $body);

    // Save the service ID
    Capsule::table("tblhosting")
        ->where("id", $params["serviceid"])
        ->update(["dedicatedip" => $deploy["service_id"]]);

    // Check if service is paid
    if (!$deploy["paid"]) {
        return "success";
    }

    $service = dashflo_Api("GET", "/manage/" . $deploy["service_id"]);

    // Save credentials
    localAPI("UpdateClientProduct", [
        "serviceid" => $params["serviceid"],
        "servicepassword" => $service["password"],
    ]);

    Capsule::table("tblhosting")
        ->where("id", $params["serviceid"])
        ->update(["username" => $service["username"]]);

    return "success";
}

/**
 * Suspends the service by sending the kill power signal.
 *
 * Called when a suspension is requested. This is invoked automatically by WHMCS
 * when a product becomes overdue on payment or can be called manually by admin
 * user.
 *
 * @param array $params common module parameters
 *
 * @return string "success" or an error message
 */
function dashflo_SuspendAccount(array $params)
{
    if (!dashflo_Id($params)) {
        return "Service not deployed";
    }

    $service = dashflo_Api("GET", "/manage/" . dashflo_Id($params));

    if ($service[status] !== "active") {
        return "Service not active at Dashflo";
    }

    if ($service[type] === "baremetal") {
        return "Unable to automatically suspend - Manually change login credentials to the server";
    }

    dashflo_Api("PUT", "/manage/" . dashflo_Id($params) . "/power", ["signal" => "kill"]);

    return "success";
}

/**
 * Cancels service at Dashflo.
 *
 * Called when a termination is requested. This can be invoked automatically for
 * overdue products if enabled, or requested manually by an admin user.
 *
 * @param array $params common module parameters
 *
 * @return string "success" or an error message
 */
function dashflo_TerminateAccount(array $params)
{
    if (!dashflo_Id($params)) {
        return "Service not deployed";
    }

    $service = dashflo_Api("GET", "/manage/" . dashflo_Id($params));

    if ($service[status] !== "active") {
        return "Service not active at Dashflo";
    }

    dashflo_Api("POST", "/manage/" . dashflo_Id($params) . "/cancel", ["reason" => "WHMCS Module - Terminate"]);

    return "success";
}

/**
 * Information about the Dashflo service.
 *
 * Displays the details of the service in the admin area service
 * information and management page within the clients profile.
 *
 * @param array $params common module parameters
 *
 * @return array
 */
function dashflo_AdminServicesTabFields(array $params)
{
    if (!dashflo_Id($params)) {
        return [
            "Dashflo Reseller" => "Service not deployed",
        ];
    }

    try {
        $service = dashflo_Api("GET", "/manage/" . dashflo_Id($params));

        // Update credentials
        localAPI("UpdateClientProduct", [
            "serviceid" => $params["serviceid"],
            "servicepassword" => $service["password"],
        ]);

        Capsule::table("tblhosting")
            ->where("id", $params["serviceid"])
            ->update(["username" => $service["username"]]);

        // Format data
        $plan =
            $service[plan][group] .
            " - " .
            $service[plan][name] .
            " " .
            ($service[plan][reseller] ? "(Reseller Compatible)" : "(Not Reseller Compatible)");
        $renews = fromMySQLDate($service["next_due_at"]);
        $started = fromMySQLDate($service["started_at"]);

        return [
            "Status" => htmlspecialchars(ucfirst($service[status])),
            "Dedicated IP" => htmlspecialchars($service[dedicated_ip]) ?: "N/A",
            "Plan" => htmlspecialchars($plan),
            "Billing Cycle" => htmlspecialchars(ucfirst($service[billing_cycle])),
            "Recurring Amount" => htmlspecialchars($service[recurring_amount]),
            "Next Due" => $renews,
            "Started At" => $started,
        ];
    } catch (Exception $e) {
        return [
            "Dashflo Reseller" => "Could not fetch service - Ensure the service ID is valid",
        ];
    }
}

/**
 * Client area output logic handling.
 *
 * Returns the data and template files for generating the
 * page output in the client area.
 *
 * @param array $params common module parameters
 *
 * @return array
 */
function dashflo_ClientArea(array $params)
{
    // Return nothing if performing custom action
    if ($_REQUEST["mng"]) {
        return;
    }

    // Get Dashflo service ID
    $id = dashflo_Id($params);

    // Return error to user if service not deployed
    if (!$id) {
        return Lang::trans("cPanel.statusPendingNotice");
    }

    $information = [];

    // Build client area page
    try {
        $service = dashflo_Api("GET", "/manage/" . dashflo_Id($params));

        // Check if service is active
        if ($service[status] !== "active") {
            return Lang::trans("cPanel.statusPendingNotice");
        }

        // Return nothing if the service isn't reseller compatible
        if (!$service[plan][reseller]) {
            return;
        }

        if ($service[plan][type] === "minecraft") {
            $templateFile = "minecraft/index";

            $information[service] = $service;
            $information[console] = dashflo_Api("GET", "/manage/" . $id . "/console");
        } elseif ($service[plan][type] === "vps") {
            $templateFile = "vps/index";

            $information[service] = $service;
            $information[console][novnc] = dashflo_Api("GET", "/manage/" . $id . "/console");
            $information[console][xtermjs] = dashflo_Api("GET", "/manage/" . $id . "/console?type=xtermjs");
        } elseif ($service[plan][type] === "baremetal") {
            $templateFile = "baremetal/index";

            $information[service] = $service;
        } else {
            return;
        }
    } catch (Exception $e) {
        return "An error occured";
    }

    return [
        "templatefile" => "templates/" . $templateFile,
        "vars" => [
            "dashflo" => $information,
        ],
    ];
}

/**
 * Additional page output logic handling.
 *
 * Called from the graphical management panel within the client area.
 *
 * @param array $params common module parameters
 *
 * @return array
 */
function dashflo_Management($params)
{
    // Get Dashflo service ID
    $id = dashflo_Id($params);

    // Return error to user if service not deployed
    if (!$id) {
        return Lang::trans("cPanel.statusPendingNotice");
    }

    // Identify requested action
    $requestedAction = $_REQUEST["mng"];

    $information = [];

    // Build client area page
    try {
        $service = dashflo_Api("GET", "/manage/" . dashflo_Id($params));

        // Check if service is active
        if ($service[status] !== "active") {
            return Lang::trans("cPanel.statusPendingNotice");
        }

        // Return nothing if the service isn't reseller compatible
        if (!$service[plan][reseller]) {
            return;
        }

        if ($service[plan][type] === "minecraft") {
            if ($requestedAction === "network") {
                // Page: network
                $templateFile = "minecraft/network";
                $templateName = "Network";

                $information[service] = $service;
                $information[network] = dashflo_Api("GET", "/manage/" . $id . "/network");
            } elseif ($requestedAction === "databases") {
                // Page: databases
                $templateFile = "minecraft/databases";
                $templateName = "Databases";

                $information[service] = $service;
                $information[databases] = dashflo_Api("GET", "/manage/" . $id . "/databases");
            } elseif ($requestedAction === "files") {
                // Page: files
                $templateFile = "minecraft/files";
                $templateName = "Files";

                $information[service] = $service;
            } else {
                return "Unknown page";
            }
        } elseif ($service[plan][type] === "vps") {
            if ($requestedAction === "network") {
                // Page: files
                $templateFile = "vps/network";
                $templateName = "Network";

                $information[service] = $service;
                $information[network] = dashflo_Api("GET", "/manage/" . $id . "/network");
            } elseif ($requestedAction === "reinstall") {
                // Page: files
                $templateFile = "vps/reinstall";
                $templateName = "Reinstall";

                $information[service] = $service;
                $information[templates] = dashflo_Api("GET", "/manage/" . $id . "/templates");
            } else {
                return "Unknown page";
            }
        } else {
            return "Unknown page";
        }
    } catch (Exception $e) {
        return "An error occured";
    }

    return [
        "templatefile" => "templates/" . $templateFile,
        "breadcrumb" => [
            "clientarea.php" => $templateName,
        ],
        "vars" => [
            "dashflo" => $information,
        ],
    ];
}

/**
 * Runs the requested logic.
 *
 * Called from the graphical management panel within the client area.
 *
 * @param array $params common module parameters
 *
 * @return string "success" or an error message
 */
function dashflo_Logic($params)
{
    // Get Dashflo service ID
    $id = dashflo_Id($params);

    // Return error to user if service not deployed
    if (!$id) {
        return Lang::trans("cPanel.statusPendingNotice");
    }

    // Identify requested action
    $requestedAction = $_REQUEST["call"];

    // Run logic
    try {
        if ($requestedAction === "DatabasesCreate") {
            dashfloLogic_DatabasesCreate($id, $params);
        } elseif ($requestedAction === "DatabasesReset") {
            dashfloLogic_DatabasesReset($id, $params);
        } elseif ($requestedAction === "DatabasesDelete") {
            dashfloLogic_DatabasesDelete($id, $params);
        } elseif ($requestedAction === "Power") {
            dashfloLogic_Power($id, $params);
        } elseif ($requestedAction === "Reinstall") {
            dashfloLogic_Reinstall($id, $params);
        } else {
            return "Unknown call";
        }
    } catch (Exception $e) {
        return "An error occured";
    }

    return "success";
}

/**
 * Additional actions a client user can invoke.
 *
 * @return array
 */
function dashflo_ClientAreaAllowedFunctions()
{
    return [
        "management" => "management",
        "logic" => "logic",
    ];
}
