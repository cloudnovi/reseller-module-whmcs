<!-- Back -->
<a href="clientarea.php?action=productdetails&id={$serviceid}" class="btn btn-primary mb-3"><i class="fas fa-arrow-left mr-2"></i> {$LANG.back}</a>

<!-- MySQL Databases -->
<div class="panel panel-default card">
    <div class="panel-heading card-header">
        <div class="row">
            <div class="col-sm-6 text-left">
                <h3 class="panel-title card-title mb-0">{$LANG.cPanel.mysqlDatabases}</h3>
            </div>
            <div class="col-sm-6 text-right">
                <button class="btn btn-xs btn-primary action {if $dashflo.databases.usage.used == $dashflo.databases.usage.limit}disabled"{else}" data-action="create"{/if}>Create New ({$dashflo.databases.usage.used}/{$dashflo.databases.usage.limit})</button>
            </div>
        </div>
    </div>
    <div class="text-left table-responsive">
        {if $dashflo.databases.usage.used === 0}
            <div class="panel-body card-body">
                <h5 class="mb-0">{$LANG.norecordsfound}<h5>
            </div>
        {else}
            <table class="table table-striped mb-0">
                <thead>
                    <tr>
                        <th>DB</th>
                        <th>{$LANG.serverusername}</th>
                        <th>{$LANG.serverpassword}</th>
                        <th>{$LANG.serverhostname}</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    {foreach from=$dashflo.databases.databases key=i item=db}
                        <tr>
                            <td>{$db.database}</td>
                            <td>{$db.username}</td>
                            <td>
                                <code class="toggle-display" style="cursor:pointer">
                                    &bull;&bull;&bull;&bull;&bull;&bull;&bull;&bull;
                                </code>
                                <code class="hidden d-none" data-attr="password">
                                    {$db.password}
                                </code>
                            </td>
                            <td>{$db.host}:3306</td>
                            <td>
                                <button class="btn btn-xs btn-danger pull-right float-right action" data-action="delete" data-id="{$db.id}" data-toggle="tooltip" title="{$LANG.delete}">
                                    <i class="fas fa-trash"></i>
                                </button>
                                <button class="btn btn-xs btn-primary pull-right float-right action" style="margin-right:10px;" data-action="reset" data-id="{$db.id}" data-toggle="tooltip" title="{$LANG.clientareanavchangepw}">
                                    <i class="fas fa-key"></i>
                                </button>
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        {/if}
    </div>
</div>

<!-- Scripts -->
<script>
    $(document).on("click", '[data-action="create"]', function () {
        $(".action").addClass("disabled");

        $.get("{$systemurl}clientarea.php", {
            action: "productdetails",
            id: "{$serviceid}",
            modop: "custom",
            a: "logic",
            call: "DatabasesCreate",
        })
            .done((data) => {
                const db = JSON.parse(data);

                $(".table tr:last").after(`
                    {literal}
                        <tr>
                            <td>${db.database}</td>
                            <td>${db.username}</td>
                            <td>
                                <code class="toggle-display" style="cursor:pointer">
                                    &bull;&bull;&bull;&bull;&bull;&bull;&bull;&bull;
                                </code>
                                <code class="hidden d-none" data-attr="password">
                                    ${db.password}
                                </code>
                            </td>
                            <td>${db.host}:3306</td>
                            <td>
                                <button class="btn btn-xs btn-danger pull-right float-right action" data-action="delete" data-id="${db.id}">
                                    <i class="fas fa-trash"></i>
                                </button>
                                <button class="btn btn-xs btn-primary pull-right float-right action" style="margin-right:10px;" data-action="reset" data-id="${db.id}">
                                    <i class="fas fa-key"></i>
                                </button>
                            </td>
                        </tr>
                    {/literal}
                    `);
            })
            .fail(() => {
                alert("{$LANG.clientareaerroroccured}");
            })
            .complete(() => {
                $(".action").removeClass("disabled");
            });
    });

    $(document).on("click", '[data-action="reset"]', function () {
        $(".action").addClass("disabled");

        const interact = $(this).closest("tr").find('code[data-attr="password"]');

        $.get("{$systemurl}clientarea.php", {
            action: "productdetails",
            id: "{$serviceid}",
            modop: "custom",
            a: "logic",
            call: "DatabasesReset",
            logic_Database: $(this).data("id"),
        })
            .done(function (data) {
                interact.text(JSON.parse(data).password);
            })
            .fail(function () {
                alert("{$LANG.clientareaerroroccured}");
            })
            .complete(function () {
                $(".action").removeClass("disabled");
            });
    });

    $(document).on("click", '[data-action="delete"]', function () {
        $(".action").addClass("disabled");

        const interact = $(this).closest("tr");

        $.get("{$systemurl}clientarea.php", {
            action: "productdetails",
            id: "{$serviceid}",
            modop: "custom",
            a: "logic",
            call: "DatabasesDelete",
            logic_Database: $(this).data("id"),
        })
            .done(function() {
                interact.remove();
            })
            .fail(function() {
                alert("{$LANG.clientareaerroroccured}");
            })
            .complete(function() {
                $(".action").removeClass("disabled");
            });
    });

    $(document).on("click", ".toggle-display", function () {
        $(this).parent().find('code[data-attr="password"]').removeClass("hidden d-none");
        $(this).hide();
    });
</script>

<!-- Styles -->
<style>
    .mb-3, .my-3 {
        margin-bottom: 1rem;
    }
</style>