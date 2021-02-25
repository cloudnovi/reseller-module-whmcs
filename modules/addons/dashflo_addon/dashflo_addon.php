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

require_once __DIR__ . "../../../servers/dashflo/lib/http.php";

require_once __DIR__ . "/version.php";

use WHMCS\Database\Capsule;

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

/**
 * Admin Area Output.
 *
 * Called when the addon module is accessed via the admin area.
 * Should return HTML output for display to the admin user.
 *
 * @return string
 */
function dashflo_addon_output($vars)
{
    // Get products that use Dashflo module
    $products = Capsule::table("tblproducts")
        ->where("servertype", "dashflo")
        ->get();

    // Get services that use Dashflo reseller products
    foreach ($products as $product) {
        $service = Capsule::table("tblhosting")
            ->where("packageid", $product->id)
            ->get();
        $services[] = json_decode(json_encode($service), true);
    }

    if (version_compare(dashflo_version(), dashflo_Api("GET", "/reseller/module/whmcs")["latest"]) < 0) {
        echo '
    <div class="errorbox">
        <strong><span class="title">Module Outdated</span></strong><br> 
        Read the documentation for instructions on how to update.
    </div>
        ';
    }
    
    echo '
    <h2 style="margin-top: 20px; margin-bottom: 10px;">Services</h2>
    <p>View the associated Dashflo service linked to your services</p>
    <table class="datatable" width="100%" border="0" cellspacing="1" cellpadding="3">
        <thead>
            <tr>
                <th>Service</th>
                <th>Dashflo Service</th>
                <th>Client</th>
            </tr>
        </thead>
        <tbody>
    ';

    foreach ($services as $service) {
        $whmcs = $service[0];
        $user = Capsule::table("tblclients")->where("id", $whmcs["userid"])->first();

        try {
            $reseller = dashflo_Api("GET", "/manage/" . $whmcs["dedicatedip"]);
        } catch (Exception $e) {}

        $row1 = '<a href="clientsservices.php?productselect='.$whmcs["id"].'">#'.$whmcs["id"].' <b>'.$products->where("id", $whmcs["packageid"])->pluck('name')[0].'</b></a> <span class="label '.strtolower($whmcs["domainstatus"]).'">'.$whmcs["domainstatus"].'</span>';
        $row3 = '<a href="clientssummary.php?userid='.$whmcs["userid"].'">'.$user->firstname.' '.$user->lastname.'</a>';
        if ($whmcs["dedicatedip"]) {
            $row2 = '<a href="https://dashflo.net/service/'.$whmcs["dedicatedip"].'" target="_blank">#'.$whmcs["dedicatedip"].' <b>'.$reseller["plan"]["group"].'</b> '.$reseller["plan"]["name"].'</a> <span class="label '.$reseller["status"].'">'.ucfirst($reseller["status"]).'</span>';
        } else{
            $row2 = '';
        }

        echo '<tr><td>'.$row1.'</td><td>'.$row2.'</td><td>'.$row3.'</td></tr>';
    }

    echo '
        </tbody>
    </table>

    <br>
    
    <div class="row">
        <div class="col-sm-4">
            <a href="https://dashflo.net/client/" target="_blank" class="btn btn-default btn-block"><i class="fas fa-home"></i> Dashboard</a>
        </div>
        <div class="col-sm-4">
            <a href="https://dashflo.net/reseller" target="_blank" class="btn btn-default btn-block"><i class="fas fa-book"></i> Documentation</a>
        </div>
        <div class="col-sm-4">
            <a href="https://dashflo.net/tickets/new" target="_blank" class="btn btn-default btn-block"><i class="fas fa-life-ring"></i> Support</a>
        </div>
    </div>
    ';
}
