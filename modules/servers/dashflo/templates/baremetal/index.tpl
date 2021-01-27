<!-- Details -->
<div class="row mb-3 text-left">
    <div class="col-4 col-xs-4">
        <b>IP: </b> {$dashflo.service.dedicated_ip}
    </div>
    <div class="col-4 col-xs-4">
        <b>Username: </b> {$dashflo.service.password}
    </div>
    <div class="col-4 col-xs-4">
        <b>Password: </b>
        <code class="toggle-display" style="cursor:pointer">
            &bull;&bull;&bull;&bull;&bull;&bull;&bull;&bull;
        </code>
        <code class="hidden d-none" data-attr="set-password">
            {$dashflo.service.password}
        </code>
    </div>
</div>

<hr class="mt-3 mb-4">

<!-- Power controls -->
<div class="row">
    <div class="col-sm-6 col-md-3 mb-2 mb-md-0">
        <button class="btn btn-block btn-info power" data-attr="power" data-action="restart" data-toggle="tooltip" title="Soft Reboot (CTRL + ALT + DEL)"><i class="fas fa-sync-alt"></i></button>
    </div>
    <div class="col-sm-6 col-md-3 mb-2 mb-md-0">
        <button class="btn btn-block btn-danger power" data-attr="power" data-action="reset" data-toggle="tooltip" title="Hard Reboot (Reset)"><i class="fas fa-sync-alt"></i></button>
    </div>
</div>

<!-- Scripts -->
<script>
    $('[data-attr="power"]').click(function (event) {
        $(".power").addClass("disabled");
        $.get("{$systemurl}clientarea.php", {
            action: "productdetails",
            id: "{$serviceid}",
            modop: "custom",
            a: "logic",
            call: "Power",
            logic_Signal: $(this).data("action"),
        })
            .fail(() => {
                alert("{$LANG.clientareaerroroccured}");
            })
            .complete(() => {
                $(".power").removeClass("disabled");
            });
    });

    $(".toggle-display").on("click", function () {
        $(this).parent().find('code[data-attr="set-password"]').removeClass("hidden d-none");
        $(this).hide();
    });
</script>