function display_row(table, url, slug, ccount, fccount, risk, jsondata) {
    var row = table.insertRow(-1);
    row.className = "row";

    var newurl = row.insertCell(0);
    var newccount = row.insertCell(1);
    var newfccount = row.insertCell(2);
    var newrisk = row.insertCell(3);
    var newjson = row.insertCell(4);

    newurl.className = "table-data is-family-code url";
    newccount.className = "table-data is-family-code ccount";
    newfccount.className = "table-data is-family-code fccount";
    newrisk.className = "table-data is-family-code risk";
    newjson.className = "table-data is-family-code json";
    
    var a = document.createElement("a");
    var link = document.createTextNode(slug);
    a.appendChild(link);
    a.href = url;
    a.setAttribute("target", "_blank");
    newurl.appendChild(a);

    var riskspan = document.createElement("span");
    riskspan.innerHTML = risk;

    newrisk.appendChild(riskspan);
    newccount.innerHTML = ccount;
    newfccount.innerHTML = fccount;

    if(risk == "high"){
        riskspan.className += " highrisk";
    } else if (risk == "critical"){
        riskspan.className += " criticalrisk";
    } else if (risk == "low") {
        riskspan.className += " lowrisk";
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