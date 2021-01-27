<!-- Back -->
<a href="clientarea.php?action=productdetails&id={$serviceid}" class="btn btn-primary mb-3"><i class="fas fa-arrow-left mr-2"></i> {$LANG.back}</a>

<!-- SFTP details -->
<div class="panel panel-default card">
    <div class="panel-heading card-header">
        <h3 class="panel-title card-title mb-0">{$LANG.cPanel.fileManager}</h3>
    </div>
    <div class="panel-body card-body text-left">
        <small>Your SFTP connection address. Paste this into FileZilla or WinSCP.</small>
        <div class="input-group">
            <input type="text" class="form-control" id="sftp" value="sftp://r{$dashflo.service.id}.{$dashflo.service.username}:{$dashflo.service.password|escape:'url'}@{$dashflo.service.dedicated_ip}:2022" readonly>
            <div class="input-group-btn ml-1">
                <button class="btn btn-default" data-toggle="tooltip" title="{$LANG.networkissuesstatusopen}" onclick="launchSftp()"><i class="fas fa-external-link-square-alt"></i></button>
                <button class="btn btn-primary js-copy" data-toggle="tooltip" title="{$LANG.generatePassword.copyAndInsert|truncate:20}" onclick="copyToClipboard()"><i class="fas fa-copy"></i></button>
            </div>
        </div>
        
        <div class="row top-buffer mt-3">
            <div class="col-sm-5 text-sm-right">
                {$LANG.serverhostname}
            </div>
            <div class="col-sm-7 mb-2 mb-sm-0">
                {$dashflo.service.dedicated_ip}
            </div>
            <div class="col-sm-5 text-sm-right">
                {$LANG.serverusername}
            </div>
            <div class="col-sm-7 mb-2 mb-sm-0">
                r{$dashflo.service.id}.{$dashflo.service.username}
            </div>
            <div class="col-sm-5 text-sm-right">
                {$LANG.serverpassword}
            </div>
            <div class="col-sm-7 mb-2 mb-sm-0">
                {$dashflo.service.password}
            </div>
            <div class="col-sm-5 text-sm-right">
                SFTP Port
            </div>
            <div class="col-sm-7">
                2022
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script>
    const copyToClipboard = () => {
        const text = document.getElementById("sftp");

        text.select();
        text.setSelectionRange(0, 99999); // For mobile devices

        document.execCommand("copy");
    };

    const launchSftp = () => {
        const text = document.getElementById("sftp");

        window.open(text.value)
    };
</script>

<!-- Styles -->
<style>
    .mb-3, .my-3 {
        margin-bottom: 1rem;
    }
</style>