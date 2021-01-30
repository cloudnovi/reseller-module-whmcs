<!-- Minecraft terminal -->
<div class="row">
    <div class="col-12">
        <div class="panel-body position-relative text-left">
            <div id="terminal" style="width:100%;"></div>
            <div id="terminal_input" class="form-group no-margin">
                <div class="input-group">
                    <div class="input-group-addon terminal_input--prompt my-auto">{$LANG.networkissuestypeserver|lower}:~#</div>
                    <input type="text" class="form-control terminal_input--input">
                </div>
            </div>
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

<hr class="d-none">

<!-- Resource graphs -->
<div class="row top-buffer mt-3">
    <div class="col-md-6">
        <div class="panel panel-default graphs card">
            <div class="panel-heading with-border card-header">
                <h5 class="panel-title card-title mb-0">{$LANG.vpsnetcpugraphs}</h5>
            </div>
            <div class="panel-body card-body p-0 pt-3">
                <canvas id="chart_cpu" style="max-height:300px;"></canvas>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="panel panel-default graphs card">
            <div class="panel-heading with-border card-header">
                <h5 class="panel-title card-title mb-0">RAM Graphs</h5>
            </div>
            <div class="panel-body card-body p-0 pt-3">
                <canvas id="chart_memory" style="max-height:300px;"></canvas>
            </div>
        </div>
    </div>
</div>

<hr class="mt-4 mb-3">

<!-- Quick links -->
<div class="row">
    <div class="col-sm-6 col-md-4 mb-2 mb-md-0">
        <a href="clientarea.php?action=productdetails&id={$serviceid}&modop=custom&a=management&mng=network" class="btn btn-block btn-primary py-3"><i class="fas fa-network-wired mr-2"></i> Network</a>
    </div>
    <div class="col-sm-6 col-md-4 mb-2 mb-md-0">
        <a href="clientarea.php?action=productdetails&id={$serviceid}&modop=custom&a=management&mng=files" class="btn btn-block btn-primary py-3"><i class="fas fa-folder-open mr-2"></i> Files (SFTP)</a>
    </div>
    <div class="col-sm-6 col-md-4 mb-2 mb-md-0">
        <a href="clientarea.php?action=productdetails&id={$serviceid}&modop=custom&a=management&mng=databases" class="btn btn-block btn-primary py-3"><i class="fas fa-database mr-2"></i> Databases</a>
    </div>
</div>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/ansi_up@4.0.4/ansi_up.js" integrity="sha256-+3I9OCf3onod3flMlC6fLgJu7vDLs1LBlPzTOMo/+Eo=" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.3.0/Chart.min.js" integrity="sha256-w8BXa9KXx+nmhO9N4hupvlLy+cAtqEarnB40DVJx2xA=" crossorigin="anonymous"></script>
<script>
    const ansi_up = new AnsiUp;
    const ws = new WebSocket("{$dashflo.console.socket}");

    ws.onopen = event => {
        ws.send({literal}'{"event":"auth","args":["{/literal}{$dashflo.console.token}"]}'); 
    };

    ws.onmessage = event => {
        const line = JSON.parse(event.data)
    
        if(line.event === "auth success") ws.send({literal}'{"event":"send logs","args":[null]}'{/literal})
        if(line.event === "stats") updateCharts(line.args[0])
        if(line.event === "token expired") location.reload()
        if(line.event === "console output") {
            pushToTerminal(line.args[0])
            scrollToBottom()
        };
    }
    
    const pushToTerminal = (string) => {
        if (!string.includes(atob("W1B0ZXJvZGFjdHlsIERhZW1vbl0=")))
            $('#terminal').append('<div class="cmd">' + ansi_up.ansi_to_html(string + '\u001b[0m') + '</div>');
    }

    const scrollToBottom = () => {
        const element = document.getElementById("terminal");
        element.scrollTop = element.scrollHeight;
    }

    const updateCharts = (data) => {
        const usage = JSON.parse(data)
    
        if (CPUData.length > 10) {
            CPUData.shift();
            MemoryData.shift();
            TimeLabels.shift();
        }
    
        CPUData.push(usage.cpu_absolute);
        MemoryData.push(parseInt(526626816 / (1024 * 1024)));
    
        TimeLabelsDate = new Date();
        TimeLabelsText = TimeLabelsDate.toTimeString();
        TimeLabels.push(TimeLabelsText.split(' ')[0]);
    
        CPUChart.update();
        MemoryChart.update();
    }
    
    {literal}
    $('[data-attr="power"]').click(function (event) {
        ws.send(`{"event":"set state","args":["${$(this).data("action")}"]}`);
    });

    $('.terminal_input--input').on('keyup', function (e) {
        if (e.which === 27) $(this).val('')

        if (e.which === 13) {
            ws.send(JSON.stringify({"event":"send command","args":[$(this).val()]})); 
            $(this).val('');
        }
    });
    {/literal}
</script>
<script>
    let TimeLabels = [];
    let CPUData = [];
    let MemoryData = [];

    const ctc = $("#chart_cpu");
    const CPUChart = new Chart(ctc, {
        type: "line",
        data: {
            labels: TimeLabels,
            datasets: [
                {
                    label: "Percent Use",
                    fill: false,
                    lineTension: 0.03,
                    backgroundColor: "#3c8dbc",
                    borderColor: "#3c8dbc",
                    borderCapStyle: "butt",
                    borderDash: [],
                    borderDashOffset: 0.0,
                    borderJoinStyle: "miter",
                    pointBorderColor: "#3c8dbc",
                    pointBackgroundColor: "#fff",
                    pointBorderWidth: 1,
                    pointHoverRadius: 5,
                    pointHoverBackgroundColor: "#3c8dbc",
                    pointHoverBorderColor: "rgba(220,220,220,1)",
                    pointHoverBorderWidth: 2,
                    pointRadius: 1,
                    pointHitRadius: 10,
                    data: CPUData,
                    spanGaps: false,
                },
            ],
        },
        options: {
            animation: {
                duration: 1,
            },
            legend: {
                display: false,
            },
        },
    });

    const ctm = $("#chart_memory");
    const MemoryChart = new Chart(ctm, {
        type: "line",
        data: {
            labels: TimeLabels,
            datasets: [
                {
                    label: "Memory Use",
                    fill: false,
                    lineTension: 0.03,
                    backgroundColor: "#3c8dbc",
                    borderColor: "#3c8dbc",
                    borderCapStyle: "butt",
                    borderDash: [],
                    borderDashOffset: 0.0,
                    borderJoinStyle: "miter",
                    pointBorderColor: "#3c8dbc",
                    pointBackgroundColor: "#fff",
                    pointBorderWidth: 1,
                    pointHoverRadius: 5,
                    pointHoverBackgroundColor: "#3c8dbc",
                    pointHoverBorderColor: "rgba(220,220,220,1)",
                    pointHoverBorderWidth: 2,
                    pointRadius: 1,
                    pointHitRadius: 10,
                    data: MemoryData,
                    spanGaps: false,
                },
            ],
        },
        options: {
            animation: {
                duration: 1,
            },
            legend: {
                display: false,
            },
        },
    });
</script>

<!-- Styles -->
<style>
    @import 'https://fonts.googleapis.com/css?family=Source+Code+Pro';
    #terminal-body {
        background: #1a1a1a;
        margin: 0;
        width: 100%;
        height: 100%;
        overflow: hidden
    }
    #terminal {
        font-family: source code pro, monospace;
        color: #dfdfdf;
        background: #1a1a1a;
        font-size: 12px;
        line-height: 14px;
        padding: 10px 10px 0;
        box-sizing: border-box;
        height: 350px;
        max-height: 500px;
        overflow-y: auto;
        overflow-x: hidden;
        border-radius: 5px 5px 0 0
    }
    #terminal>.cmd {
        padding: 1px 0
    }
    #terminal_input {
        width: 100%;
        background: #1a1a1a;
        border-radius: 0 0 5px 5px;
        padding: 0 0 0 10px!important
    }
    .terminal_input--input,
    .terminal_input--prompt {
        font-family: source code pro, monospace;
        margin-bottom: 0;
        border: 0!important;
        background: 0 0!important;
        color: #dfdfdf !important;
        font-size: 12px;
        padding: 1px 0 4px!important
    }
    .terminal_input--input {
        margin-left: 6px;
        line-height: 1;
        outline: none!important
    }
</style>