<!-- Back -->
<a href="clientarea.php?action=productdetails&id={$serviceid}" class="btn btn-primary mb-3"><i class="fas fa-arrow-left mr-2"></i> {$LANG.back}</a>

<!-- Firewall options -->
<form action="#" id="options">
    <div class="panel panel-default card">
        <div class="panel-heading card-header">
            <h3 class="panel-title card-title mb-0" style="margin-top: 2.5px;">{$LANG.store.sitelock.featuresFirewallTitle} {$LANG.cartconfigurationoptions}</h3>
        </div>
        <div class="text-left table-responsive">
            <table class="table mb-0">
                <tbody>
                    <tr>
                        <td>Input</td>
                        <td>
                            <div class="form-group mb-0">
                                <label for="inputSelect" class="d-none sr-only">Input</label>
                                <select class="form-control" id="inputSelect" name="input">
                                    <option {if $dashflo.options.input === "ACCEPT"}selected{/if}>ACCEPT</option>
                                    <option {if $dashflo.options.input === "DROP"}selected{/if}>DROP</option>
                                    <option {if $dashflo.options.input === "REJECT"}selected{/if}>REJECT</option>
                                </select>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td>Output</td>
                        <td>
                            <div class="form-group mb-0">
                                <label for="inputSelect" class="d-none sr-only">Output</label>
                                <select class="form-control" id="inputSelect" name="output">
                                    <option {if $dashflo.options.output === "ACCEPT"}selected{/if}>ACCEPT</option>
                                    <option {if $dashflo.options.output === "DROP"}selected{/if}>DROP</option>
                                    <option {if $dashflo.options.output === "REJECT"}selected{/if}>REJECT</option>
                                </select>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        <div class="panel-footer card-footer">
            <button class="btn btn-primary float-right" id="optionsButton"><i class="fas fa-save mr-2"></i> Save</button>
        </div>
    </div>
</form>

<!-- Scripts -->
<script>
    const optionsButton = document.getElementById("optionsButton");
    const optionsForm = document.getElementById("options");
    optionsForm.addEventListener("submit", updateOptions);

    function updateOptions(e) {
        optionsButton.disabled = true;

        const data = Object.fromEntries(new FormData(e.target).entries());

        const requestParams = new URLSearchParams({
            action: "productdetails",
            id: "{$serviceid}",
            modop: "custom",
            a: "logic",
            call: "FirewallOptions",
            logic_Input: data.input,
            logic_Output: data.output,
        });

        fetch("clientarea.php?" + requestParams).then((response) => {
            if (response.status !== 204) alert("{$LANG.clientareaerroroccured}");
            
            optionsButton.disabled = false;
        });

        e.preventDefault();
    }
</script>

<!-- Styles -->
<style>
    .mb-3, .my-3 {
        margin-bottom: 1rem;
    }
</style>