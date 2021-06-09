<!-- Details -->
<div class="row mb-3 text-left">
    <div class="col-4 col-xs-4">
        <b>IP: </b> {$dashflo.service.dedicated_ip}
    </div>
    <div class="col-4 col-xs-4">
        <b>Username: </b> {$dashflo.service.username}
    </div>
    <div class="col-4 col-xs-4">
        <b>Password: </b>
        <code class="toggle-password" style="cursor:pointer">
            &bull;&bull;&bull;&bull;&bull;&bull;&bull;&bull;
        </code>
        <code class="hidden d-none" data-attr="set-password">
            {$dashflo.service.password}
        </code>
    </div>
</div>

<hr class="mt-3 mb-4">

<!-- VPS terminal -->
<ul class="nav nav-tabs nav-pills nav-justified border-0 mb-3" id="pills-tab" role="tablist">
  <li class="nav-item active mr-1">
    <a class="nav-link active" id="pills-profile-tab" data-toggle="pill" href="#xtermjs" role="tab">
        Terminal
        <span class="badge badge-primary" onclick="popoutXtermjs()" data-toggle="tooltip" title="Open in new tab"><i class="fas fa-expand-arrows-alt"></i></span>
    </a>
  </li>
  <li class="nav-item ml-1">
    <a class="nav-link" id="pills-home-tab" data-toggle="pill" href="#novnc" role="tab">
        Monitor
        <span class="badge badge-primary my-auto" onclick="popoutNovnc()" data-toggle="tooltip" title="Open in new tab"><i class="fas fa-expand-arrows-alt"></i></span>
    </a>
  </li>
</ul>
<div class="tab-content mb-2 border-bottom-0">
  <div id="xtermjs" class="tab-pane w-100 fade in active">
    <div class="panel-body text-left">
        <iframe style="border-radius: 3px;" height="350px" width="100%" frameBorder="0" id="xtermjsTerminal" class="terminal" src="{$dashflo.console.xtermjs.url}">Failed to load console.</iframe>
    </div>
  </div>
  <div id="novnc" class="tab-pane w-100 fade in">
    <div class="panel-body text-left">
        <iframe style="border-radius: 3px;" height="350px" width="100%" frameBorder="0" id="novncTerminal" class="terminal" src="{$dashflo.console.novnc.url}" allowfullscreen>Failed to load console.</iframe>
    </div>
  </div>
</div>

<!-- Power controls -->
<div class="row">
    <div class="col-sm-6 col-md-3 mb-2 mb-md-0">
        <button class="btn btn-block btn-success power" data-attr="power" data-action="start" data-toggle="tooltip" title="{$LANG.poweron}"><i class="fas fa-play"></i></button>
    </div>
    <div class="col-sm-6 col-md-3 mb-2 mb-md-0">
        <button class="btn btn-block btn-info power" data-attr="power" data-action="restart" data-toggle="tooltip" title="{$LANG.powerreboot}"><i class="fas fa-sync-alt"></i></button>
    </div>
    <div class="col-sm-6 col-md-3 mb-2 mb-md-0">
        <button class="btn btn-block btn-danger power" data-attr="power" data-action="stop" data-toggle="tooltip" title="{$LANG.powershutdown}"><i class="fas fa-stop"></i></button>
    </div>
    <div class="col-sm-6 col-md-3 mb-2 mb-md-0">
        <button class="btn btn-block btn-danger power" data-attr="power" data-action="kill" data-toggle="tooltip" title="{$LANG.poweroffforced}"><i class="fas fa-plug"></i></button>
    </div>
</div>

<hr class="mt-4 mb-3">

<!-- Quick links -->
<div class="row">
    <div class="col-sm-6 col-md-4 mb-2 mb-md-0">
        <a href="clientarea.php?action=productdetails&id={$serviceid}&modop=custom&a=management&mng=network" class="btn btn-block btn-primary py-3"><i class="fas fa-network-wired mr-2"></i> Network</a>
    </div>
    <div class="col-sm-6 col-md-4 mb-2 mb-md-0">
        <a href="clientarea.php?action=productdetails&id={$serviceid}&modop=custom&a=management&mng=reinstall" class="btn btn-block btn-primary py-3"><i class="fas fa-retweet mr-2"></i> Reinstall</a>
    </div>
    <div class="col-sm-6 col-md-4 mb-2 mb-md-0">
        <a href="clientarea.php?action=productdetails&id={$serviceid}&modop=custom&a=management&mng=firewall" class="btn btn-block btn-primary py-3"><i class="fas fa-fire mr-2"></i> Firewall</a>
    </div>
</div>

<!-- Scripts -->
<script>
    if ($.fn.tooltip.Constructor.VERSION.charAt(0) === "4") $("#xtermjs").addClass("show");

    const popoutXtermjs = () => {
        const popout = window.open();
        popout.document.write('<iframe height="100%" width="100%" frameborder="0" src="{$dashflo.console.xtermjs.url}"></iframe>');
        popout.document.body.style.margin = "0px";
    };
    const popoutNovnc = () => {
        const popout = window.open();
        popout.document.write('<iframe height="100%" width="100%" frameborder="0" src="{$dashflo.console.novnc.url}"></iframe>');
        popout.document.body.style.margin = "0px";
    };

    $('[data-attr="power"]').click(function () {
        $(".power").addClass("disabled");

        const requestParams = new URLSearchParams({
            action: "productdetails",
            id: "{$serviceid}",
            modop: "custom",
            a: "logic",
            call: "Power",
            logic_Signal: $(this).data("action"),
        });

        fetch("clientarea.php?" + requestParams).then((response) => {
            if (response.status !== 204) alert("{$LANG.clientareaerroroccured}");
            
            $(".terminal").attr("src", function (i, val) {
                return val;
            });
            $(".power").removeClass("disabled")
        });
    });

    $(".toggle-password").on("click", function () {
        $(this).parent().find('code[data-attr="set-password"]').removeClass("hidden d-none");
        $(this).hide();
    });
</script>