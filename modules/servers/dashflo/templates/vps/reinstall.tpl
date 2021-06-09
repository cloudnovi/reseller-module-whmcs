<!-- Back -->
<a href="clientarea.php?action=productdetails&id={$serviceid}" class="btn btn-primary mb-3"><i class="fas fa-arrow-left mr-2"></i> {$LANG.back}</a>

<!-- Reinstall -->
<div class="panel panel-default card">
    <div class="panel-heading card-header">
        <h3 class="panel-title card-title mb-0" style="margin-top: 2.5px;">Reinstall</h3>
    </div>
    <div class="text-left table-responsive">
        {if $dashflo.templates.templates|count === 0}
            <div class="panel-body card-body">
                <h5 class="mb-0">{$LANG.norecordsfound}<h5>
            </div>
        {else}
            <table class="table table-striped mb-0">
                <tbody>
                    {foreach from=$dashflo.templates.templates key=i item=tpl}
                        <tr>
                            <td>{$tpl}</td>
                            <td>
                                <button class="btn btn-xs btn-primary pull-right float-right action" data-action="reinstall" data-id="{$tpl}">
                                    Reinstall <i class="fas fa-arrow-right ml-1"></i>
                                </button>
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        {/if}
    </div>
</div>

<!-- Reinstall confirmation modal -->
<div class="modal" tabindex="-1" role="dialog" id="reinstall">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Reinstall Started</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p class="mb-0">The reinstall of this service has started. Please wait a few minutes for the reinstall to complete.</p>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script>
    $('[data-action="reinstall"]').click(function () {
        $(".action").addClass("disabled");

        const requestParams = new URLSearchParams({
            action: "productdetails",
            id: "{$serviceid}",
            modop: "custom",
            a: "logic",
            call: "Reinstall",
            logic_Template: $(this).data("id"),
        });

        fetch("clientarea.php?" + requestParams).then((response) => {
            if (response.status !== 204) alert("{$LANG.clientareaerroroccured}");

            $("#reinstall").modal("show")
            $(".action").removeClass("disabled")
        });
    });

    $("#reinstall").on("hidden.bs.modal", function () {
        window.location.href = "clientarea.php?action=productdetails&id={$serviceid}";
    });
</script>

<!-- Styles -->
<style>
    .mb-3, .my-3 {
        margin-bottom: 1rem;
    }
</style>