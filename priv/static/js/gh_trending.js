function displayRow(table, url, ccount, fccount, risk, jsondata) {
    var row = table.insertRow(-1);
    row.className = "row";

    //obj notation
    var newurl = row.insertCell(0);
    var newccount = row.insertCell(1);
    var newfccount = row.insertCell(2)
    var newrisk = row.insertCell(3);
    var newjson = row.insertCell(4);

    newurl.className = "table-data is-family-code url";
    newccount.className = "table-data is-family-code ccount";
    newfccount.className = "table-data is-family-code fccount";
    newrisk.className = "table-data is-family-code risk";
    newjson.className = "table-data is-family-code json";
    
    newurl.innerHTML = url;
    newccount.innerHTML = ccount;
    newfccount.innerHTML = fccount;
    newrisk.innerHTML = risk;

    var button = document.createElement("Button");
    button.innerHTML = "view";
    button.className = "button is-danger is-small is-family-code";
    newjson.appendChild(button);

    var div = document.createElement("div");
    div.className = "box tree";
    div.style.display = "none"
    var tree = jsonTree.create(jsondata, div);
    newjson.appendChild(div);

    button.addEventListener('click', () => {
        if (div.style.display == "none") {
            button.textContent = "Hide";
            div.style.display = "block";
        } else {
            button.textContent = "view";
            tree.collapse();
            div.style.display = "none";
        }
    });
}