// Opens a modal window for confirming user actions before making request to server
function openWindow(id, action, info) {
    // Get modal
    var modal = document.getElementById("window");
    modal.style.display = "block";

    // Modal content
    var body = modal.querySelector(".modal-body");
    // Find or create title
    var title = body.querySelector("#modalTitle");
    if (title == null) {
        title = body.appendChild(document.createElement("h1"));
        title.setAttribute("id", "modalTitle");
    }
    // Find or create inner text
    var text = body.querySelector("#modalText");
    if (text == null) {
        text = body.appendChild(document.createElement("div"));
        text.setAttribute("id", "modalText");
        // Use three lines of info in the block
        text.appendChild(document.createElement("p"));
        text.appendChild(document.createElement("p"));
        text.appendChild(document.createElement("p"));
    }

    // Set the text inside
    if (action == "execute_lottery") {
        title.innerHTML = "Confirm Execute Lottery";
        text.children[0].innerHTML = "You are executing the lottery for <b>" + info['event_name'] + "</b>.";
        text.children[1].innerHTML = "There are currently <b>" + info['num_entries'] + "</b> users entered in this lottery.";
        text.children[2].innerHTML = "Click <b>Confirm</b> to continue."
    } else if (action == "open_lottery") {
        title.innerHTML = "Confirm Open Lottery";
        text.children[0].innerHTML = "You are opening the lottery for <b>" + info['event_name'] + "</b>.";
        text.children[1].innerHTML = "Click <b>Confirm</b> to continue."
        text.children[2].innerHTML = "";
    } else if (action == "exec_all_auctions") {
        title.innerHTML = "Execute All Auctions";
        text.children[0].innerHTML = "You are executing all auctions for <b>" + info['event_name'] + "</b>.";
        text.children[1].innerHTML = "There are currently <b>" + info['num_auctions'] + "</b> auctions for this game.";
        text.children[2].innerHTML = "Click <b>Confirm</b> to continue."
    }

    var buttonArea = modal.querySelector(".button-area");
    // Find or create Confirm button
    var confirm = buttonArea.querySelector(".confirmButton");
    if (confirm == null) {
        confirm = buttonArea.appendChild(document.createElement("button"));
        confirm.innerHTML = "Confirm";
        confirm.setAttribute("class", "confirmButton");
    }
    confirm.style.display = "block";

    // Find or create "Go Back" button
    var back = buttonArea.querySelector(".backButton");
    if (back == null) {
        back = buttonArea.appendChild(document.createElement("button"));

        back.innerHTML = "Go Back";
        back.setAttribute("class", "backButton");
        back.onclick = function(event) {
            // Close the modal
            modal.style.display = "none";
            location.reload();
        }
    }


    // On clicking confirm button, make request to execute action
    confirm.onclick = function(event) {
        // Send necessary information to backend
        var data = {
            admin: true,
            action: action,
            game_id: id,
        };

        // Send the request JSON
        $.ajax({
            type: "POST",
            contentType: "application/json",
            data: JSON.stringify(data),
            url: "/requests.pyhtml",
            error: (error) => {
                console.log(error);
                text.innerHTML = error.responseText;
            },
        }).then((data) => {
            confirm.style.display = "none";

            console.log(data);
            var resp = JSON.parse(data);
            if (resp.hasOwnProperty("error")) { // Action failed
                text.innerHTML = resp.error;
            } else { // Successful execution
                if (action == "execute_lottery") {
                    text.children[0].innerHTML = "Success! The lottery for <b>" + info['event_name'] + "</b> has been executed.";
                    text.children[1].innerHTML = "";
                    text.children[2].innerHTML = "";
                } else if (action == "open_lottery") {
                    text.children[0].innerHTML = "Success! The lottery for <b>" + info['event_name'] + "</b> is now open.";
                    text.children[1].innerHTML = "";
                    text.children[2].innerHTML = "";
                } else {
                    text.children[0].innerHTML = "Success!";
                    text.children[1].innerHTML = "";
                    text.children[2].innerHTML = "";
                }
            }
        });
    };
}

// Close the modal
function closeWindow() {
    var modal = document.getElementById('window');
    modal.style.display = "none";
    location.reload();
}

// If a modal is open and the user clicks outside of it, close the modal
window.onclick = function(event) {
    if (event.target.attributes.class && event.target.attributes.class.value == "modal") {
        event.target.style.display = "none";
        location.reload();
    }
}

// Updates the displayed user balance to reflect the selected value
function updateUserBalance() {
    // Get the user currently selected
    var selected = document.getElementById("userSelect").options[userSelect.selectedIndex];
    document.getElementById("userBalance").innerText = selected.getAttribute("data-balance");
}
