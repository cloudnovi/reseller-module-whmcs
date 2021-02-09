<?php
/**
 * Dashflo Reseller
 *
 * Resell Dashflo services to your customers
 *
 * @package    Dashflo Reseller Module for WHMCS
 * @author     Dashflo Ltd <support@dashflo.net>
 * @copyright  2018-2021 Dashflo Ltd
 * @version:   2.1.0
 * @link       https://dashflo.net/reseller
 */

if (!defined("WHMCS")) {
    die("This file cannot be accessed directly");
}

use WHMCS\Database\Capsule;

/**
 * Performs a request to the Dashflo API
 *
 * @param string $reqtype request type
 * @param string $endpoint api endpoint
 * @param array $payload optional body content
 *
 * @return array api response or an error message
 */
function dashflo_Api($reqtype, $route, array $payload = [])
{
    $api = "https://api.dashflo.net/client/v2";

    $version = Capsule::table("tblconfiguration")
        ->where("setting", "Version")
        ->value("value");
    $module = Capsule::table("tbladdonmodules")
        ->where("module", "dashflo_addon")
        ->where("setting", "password")
        ->value("value");
    $username = Capsule::table("tbladdonmodules")
        ->where("module", "dashflo_addon")
        ->where("setting", "email")
        ->value("value");
    $password = Capsule::table("tbladdonmodules")
        ->where("module", "dashflo_addon")
        ->where("setting", "password")
        ->value("value");

    $ch = curl_init($api . $route);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $reqtype);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_USERAGENT, "WHMCS (v" . $version . ") (Module: v" . $module . ")");
    curl_setopt($ch, CURLOPT_HTTPHEADER, ["username: " . $username, "password: " . $password, "Content-Type: application/json"]);

    $curl = curl_exec($ch);

    if (curl_error($ch)) {
        logModuleCall("Dashflo", $api . $route, $payload, curl_errno($ch) . " - " . curl_error($ch));
        throw new Exception("Unable to connect: " . curl_errno($ch) . " - " . curl_error($ch));
    }

    if (curl_getinfo($ch, CURLINFO_HTTP_CODE) > 300) {
        logModuleCall("Dashflo", $api . $route, $payload, $curl);
        throw new Exception("Unexpected status code: " . curl_getinfo($ch, CURLINFO_HTTP_CODE));
    }

    curl_close($ch);

    $result = json_decode($curl, true);

    logModuleCall("Dashflo", $api . $route, $payload, $curl, $result);

    return $result;
}
