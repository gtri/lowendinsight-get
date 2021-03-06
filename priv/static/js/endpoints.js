function disable_button(){
    var button = document.getElementById("analyze-button");
    button.classList.add("is-loading");
    button.setAttribute("disabled", true);
}

function get_encoded_url(){
    var input = document.getElementById("input-url");
    var url = input.value;
    return encodeURIComponent(url);
}

function display_error() {
    document.getElementById("analyze-button").classList.remove("is-loading");
    document.getElementById("input-url").classList.add("error");
    document.getElementById("invalid-url").style.display = "block";
}

function remove_error(){
    document.getElementById("input-url").classList.remove("error");
    document.getElementById("invalid-url").style.display = "none";
    document.getElementById("analyze-button").disabled = false;
    document.getElementById("analyze-button").classList.remove("is-loading");
}

async function validate_url(encoded_url){
    var is_valid_url = false;
    var is_valid_repo = false;

    await fetch(`/validate-url/url=${encoded_url}`)
        .then(validate => {
            is_valid_url = (validate.status == 200);
        }).catch(error => console.log(error))

    if(is_valid_url){
        await fetch(`/url=${encoded_url}`)
            .then(analyze => {
                is_valid_repo = (analyze.status == 200);
            }).catch(error => console.log(error))
    } 
    return is_valid_repo;
}

async function validate_and_submit(){
    event.preventDefault();
    event.stopPropagation();

    var form = document.getElementById("form");
    disable_button();

    var encoded_url = get_encoded_url();
    var is_valid_url = await validate_url(encoded_url);

    if (is_valid_url) {
      form.action = `/url=${encoded_url}`;
      form.submit();
    } else {
        display_error();
    }
}

function languages_button_event(){
    document.addEventListener('DOMContentLoaded', function () {
    
        var dropdown = document.querySelector('.dropdown');
          
        dropdown.addEventListener('click', function(event) {
            event.stopPropagation();
            dropdown.classList.toggle('is-active');
                
        });    

        document.addEventListener('click', function(e) {
            dropdown.classList.remove('is-active');
        });
    });
}

function view_json_button(json_data, parent){
    var button_text = "view";
    
    var spanbutton = document.createElement("span");
    var button = document.createElement("Button");
    if (window.matchMedia('(max-device-width: 768px)').matches) {
        button.className = "button is-info is-small is-family-code";
    } else {
        button.className = "button is-info is-family-code";   
    }
    spanbutton.innerHTML = button_text;
    spanbutton.style["font-weight"] = "bold";
    button.appendChild(spanbutton);
    parent.appendChild(button);

    var div = document.createElement("div");
    div.className = "box tree";
    div.style.display = "none";
    var tree = jsonTree.create(json_data, div);
    parent.appendChild(div);

    button.addEventListener('click', () => {
        if (div.style.display == "none") {
            spanbutton.textContent = "hide";
            div.style.display = "block";
        } else {
            spanbutton.textContent = button_text;
            tree.collapse();
            div.style.display = "none";
        }
    });
}

function display_row(project, slug, risk, ccount, fccount, large_commit_risk, commit_currency, json_data) {
    var table = document.getElementById("repo")
    var row = table.insertRow(-1);
    row.className = "row";

    var project_cell = row.insertCell(0);
    var risk_cell = row.insertCell(1);
    var ccount_cell = row.insertCell(2);
    var fccount_cell = row.insertCell(3);
    var large_commit_risk_cell = row.insertCell(4);
    var ccurreny_cell = row.insertCell(5);
    var json_cell = row.insertCell(6);

    project_cell.className = "table-data is-family-code project";
    risk_cell.className = "table-data is-family-code risk";
    ccount_cell.className = "table-data is-family-code ccount";
    fccount_cell.className = "table-data is-family-code fccount";
    large_commit_risk_cell.className = "table-data is-family-code large_commit_risk";
    ccurreny_cell.className = "table-data is-family-code commit_currency";
    json_cell.className = "table-data is-family-code json";
    
    var a = document.createElement("a");
    var link = document.createTextNode(slug);
    a.appendChild(link);
    a.href = project;
    a.setAttribute("target", "_blank");
    project_cell.appendChild(a);

    var riskspan = document.createElement("span");
    riskspan.innerHTML = risk;
    risk_cell.appendChild(riskspan);

    ccount_cell.innerHTML = ccount;
    fccount_cell.innerHTML = fccount;
    large_commit_risk_cell.innerHTML = large_commit_risk;
    ccurreny_cell.innerHTML = commit_currency;

    switch(risk){
        case "critical": 
            riskspan.className += " criticalrisk"; break;
        case "high": 
            riskspan.className += " highrisk"; break;
        case "medium": 
            riskspan.className += " mediumrisk"; break;
        case "low": 
            riskspan.className += " lowrisk"; break;
        default: break;
    }
    
    view_json_button(json_data, json_cell);
}


