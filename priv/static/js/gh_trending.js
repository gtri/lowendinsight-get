function display_row(table, project, slug, ccount, fccount, risk, jsondata) {
    var row = table.insertRow(-1);
    row.className = "row";

    var newproject = row.insertCell(0);
    var newrisk = row.insertCell(1);
    var newccount = row.insertCell(2);
    var newfccount = row.insertCell(3);
    var newjson = row.insertCell(4);

    newproject.className = "table-data is-family-code project";
    newrisk.className = "table-data is-family-code risk";
    newccount.className = "table-data is-family-code ccount";
    newfccount.className = "table-data is-family-code fccount";
    newjson.className = "table-data is-family-code json";
    
    var a = document.createElement("a");
    var link = document.createTextNode(slug);
    a.appendChild(link);
    a.href = project;
    a.setAttribute("target", "_blank");
    newproject.appendChild(a);

    var riskspan = document.createElement("span");
    riskspan.innerHTML = risk;

    newrisk.appendChild(riskspan);
    newccount.innerHTML = ccount;
    newfccount.innerHTML = fccount;

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

    var spanbutton = document.createElement("span");
    var button = document.createElement("Button");
    button.className = "button is-info is-family-code";
    spanbutton.innerHTML = "view"
    spanbutton.style["font-weight"] = "bold";
    button.appendChild(spanbutton);
    newjson.appendChild(button);

    var div = document.createElement("div");
    div.className = "box tree";
    div.style.display = "none"
    var tree = jsonTree.create(jsondata, div);
    newjson.appendChild(div);

    button.addEventListener('click', () => {
        if (div.style.display == "none") {
            spanbutton.textContent = "hide";
            div.style.display = "block";
        } else {
            spanbutton.textContent = "view";
            tree.collapse();
            div.style.display = "none";
        }
    });
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
