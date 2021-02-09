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

require_once __DIR__ . "../../../servers/dashflo/lib/http.php";

require_once __DIR__ . "/version.php";

add_hook("AdminHomeWidgets", 1, function () {
    return new DashfloResellerVersionWidget();
});

class DashfloResellerVersionWidget extends \WHMCS\Module\AbstractWidget
{
    protected $title = "Dashflo Reseller";
    protected $description = "Check the latest version of the reseller module";
    protected $weight = 150;
    protected $columns = 1;
    protected $cache = true;
    protected $cacheExpiry = 120;
    protected $requiredPermission = "";

    /**
     * Get Data.
     *
     * Obtain the latest version of the reseller module.
     *
     * @return array
     */
    public function getData()
    {
        $version = dashflo_Api("GET", "/reseller/module/whmcs")["latest"];

        if (version_compare(dashflo_version(), $version) >= 0) {
            $widget = [
                "message" => "Running latest version",
                "bg" => "success",
            ];
        } else {
            $widget = [
                "message" => "Upgrade available: v" . $version,
                "bg" => "danger",
            ];
        }

        $widget["version"] = dashflo_version();

        return $widget;
    }

    /**
     * Generate Output.
     *
     * Generate and return the body output for the widget.
     *
     * @param array $data The data returned by the getData method.
     *
     * @return string
     */
    public function generateOutput($data)
    {
        return <<<EOF
<div class="widget-content-padded bg-{$data["bg"]} text-white" onclick="window.location.href = 'addonmodules.php?module=dashflo_addon';" style="cursor:pointer">
    <div class="row">
        <div class="col-xs-8">
            <b>{$data["message"]}</b>
        </div>
        <div class="col-xs-4 text-right">
            <span class="badge" data-toggle="tooltip" title="Current Version">{$data["version"]}</span>
        </div>
    </div>
</div>
EOF;
    }
}
