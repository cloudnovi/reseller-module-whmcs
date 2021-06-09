<?php
/**
 * Dashflo Reseller
 *
 * Resell Dashflo services to your customers
 *
 * @package    Dashflo Reseller Module for WHMCS
 * @author     Dashflo Ltd <support@dashflo.net>
 * @copyright  2018-2021 Dashflo Ltd
 * @version:   2.2.0
 * @link       https://dashflo.net/reseller
 */

if (!defined("WHMCS")) {
    die("This file cannot be accessed directly");
}

require_once __DIR__ . "/lib/http.php";

use WHMCS\Database\Capsule;

/**
 * Cancels service at Dashflo.
 *
 * Called when a cancellation is requested.
 *
 * @param array $params common module parameters
 *
 * @return string "success" or an error message
 */
add_hook("CancellationRequest", 1, function ($params) {
    $id = Capsule::table("tblhosting")
        ->where("id", $params["relid"])
        ->value("dedicatedip");

    try {
        $service = dashflo_Api("GET", "/manage/" . $id);

        if ($service[status] !== "active") {
            return "Service not active on backend";
        }

        dashflo_Api("POST", "/manage/" . $id . "/cancel", ["reason" => "WHMCS Module - Cancellation Request - " . $params["reason"]]);
    } catch (Exception $e) {
        return "An error occured";
    }

    return "success";
});
