<?php
/**
 * Dashflo Reseller
 *
 * Resell Dashflo services to your customers
 *
 * @package    Dashflo Reseller Module for WHMCS
 * @author     Dashflo Ltd <support@dashflo.net>
 * @copyright  2018-2021 Dashflo Ltd
 * @version:   2.1.1
 * @link       https://dashflo.net/reseller
 */

if (!defined("WHMCS")) {
    die("This file cannot be accessed directly");
}

function dashfloLogic_DatabasesCreate($id, $params)
{
    $body = ["name" => substr(md5(microtime()), 0, 10)];

    try {
        $result = dashflo_Api("POST", "/manage/" . $id . "/databases", $body);
        echo json_encode($result);
    } catch (Exception $e) {
        $status = 500;
    }

    http_response_code($status ?: "200");
    exit();
}

function dashfloLogic_DatabasesReset($id, $params)
{
    $database = $_REQUEST["logic_Database"];

    try {
        $result = dashflo_Api("PUT", "/manage/" . $id . "/databases/" . $database . "/rotate-password");
        echo json_encode($result);
    } catch (Exception $e) {
        $status = 500;
    }

    http_response_code($status ?: "200");
    exit();
}

function dashfloLogic_DatabasesDelete($id, $params)
{
    $database = $_REQUEST["logic_Database"];

    try {
        dashflo_Api("DELETE", "/manage/" . $id . "/databases/" . $database);
    } catch (Exception $e) {
        $status = 500;
    }

    http_response_code($status ?: "204");
    exit();
}
