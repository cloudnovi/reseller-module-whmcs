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

require_once __DIR__ . "../../../servers/dashflo/lib/http.php";

require_once __DIR__ . "/version.php";

/**
 * Define addon module configuration parameters.
 *
 * @return array
 */
function dashflo_addon_config()
{
    return [
        "name" => "Dashflo Reseller",
        "description" => "Resell Dashflo services to your customers",
        "version" => dashflo_version(),
        "author" => "Dashflo",
        "fields" => [
            "email" => [
                "FriendlyName" => "Email",
                "Type" => "text",
                "Size" => "25",
                "Description" => "Email of your Dashflo account",
                "Default" => "example@example.com",
            ],
            "password" => [
                "FriendlyName" => "Password",
                "Type" => "password",
                "Size" => "25",
                "Description" => "Password of your Dashflo account",
                "Default" => "Password",
            ],
        ],
    ];
}
