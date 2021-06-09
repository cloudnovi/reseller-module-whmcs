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

function dashfloLogic_Power($id, $params)
{
    $body = [
        "signal" => $_REQUEST["logic_Signal"],
    ];

    try {
        dashflo_Api("PUT", "/manage/" . $id . "/power", $body);
    } catch (Exception $e) {
        $status = 500;
    }

    http_response_code($status ?: "204");
    exit();
}
