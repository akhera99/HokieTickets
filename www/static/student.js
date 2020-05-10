// Format ticket values into HTK (i.e. 6000 -> "60.00 HTK")
function formatHTK(value) {
    var val = value.toString();
    return val.slice(0, -2) + "." + val.slice(-2) + " HTK";
}

// Format date from YYYYMMDDHHMM to "Month" DD, YYYY
function formatDate(date) {
    var months = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
    ];

    date = date.slice(0, 8); // Cut off hours and minutes

    var month = Math.floor(date / 100) % 100;
    var day = date % 100;
    var year = Math.floor(date / 10000);

    return months[month - 1] + " " + day + ", " + year;
}

function formatTime(date) {
    var time = date.slice(8);

    var ampm = "am";
    var hour = parseInt(time.slice(0, 2));
    if (hour >= 12) {
        ampm = "pm"
    }
    hour = hour % 12;
    if (hour == 0) {
        hour = 12;
    }
    var minute = time.slice(2);

    return hour + ":" + minute + " " + ampm;
}

function formatDateForInput(date) {
    return date.slice(0, 4) + "-" + date.slice(4, 6) + "-" + date.slice(6, 8);
}

function formatTimeForInput(date) {
    return date.slice(8, 10) + ":" + date.slice(10);
}

// Opens a modal window for confirming user actions before making request to server
function openWindow(user, id, action, info) {
    // Get modal
    var modal = document.getElementById("window");
    modal.style.display = "block";

    // Modal content
    var body = modal.querySelector(".modal-body");

    // Buttons
    var buttonArea = modal.querySelector(".button-area");
    // Find or create Confirm button
    var confirm = buttonArea.querySelector(".confirmButton");
    if (confirm == null) {
        confirm = buttonArea.appendChild(document.createElement("button"));
    }
    confirm.innerHTML = "Confirm";
    confirm.setAttribute("class", "confirmButton");
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
            if ( /*action == "bid" ||*/ action == "view") return;
            location.reload();
        }
    }


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
    if (action == "buy") {
        title.innerHTML = "Confirm Ticket Purchase";
        text.children[0].innerHTML = "You are purchasing a ticket for <b>" + info['event_name'] + "</b>.";
        text.children[1].innerHTML = "Your current balance is <b>" + info['current_balance'] + " HTK</b>.";
        text.children[2].innerHTML = "Click <b>Confirm</b> to continue."
    } else if (action == "enter_lottery") {
        title.innerHTML = "Confirm Lottery Entry";
        text.children[0].innerHTML = "You are entering the lottery for <b>" + info['event_name'] + "</b>.";
        text.children[1].innerHTML = "Click <b>Confirm</b> to continue."
    } else if (action == "leave_lottery") {
        title.innerHTML = "Leaving Lottery";
        text.children[0].innerHTML = "You are leaving the lottery for <b>" + info['event_name'] + "</b>.";
        text.children[1].innerHTML = "Click <b>Confirm</b> to continue."
    } else if (action == "sell") {
        title.innerHTML = "Confirm Ticket Sale";
        text.children[0].innerHTML = "You are selling your ticket for <b>" + info['event_name'] + "</b>.";
        text.children[1].innerHTML = "Your current balance is <b>" + info['current_balance'] + " HTK</b>.";
        text.children[2].innerHTML = "Click <b>Confirm</b> to continue.";
    } else if (action == "create_auction") {
        title.innerHTML = "Confirm Ticket Auction";
        text.children[0].innerHTML = "You are auctioning your ticket for <b>" + info['event_name'] + "</b> on <b>" + formatDate(info['event_date']) + " " + formatTime(info['event_date']) + "</b>.";
        text.children[1].innerHTML = "The ticket will start at a price of <b>" + formatHTK(info['ticket_value']) + "</b>.";
        text.children[2].innerHTML = "Input your desired end date for the auction, and press <b>Continue</b> to submit.";

        var inputArea = body.querySelector("#inputArea");
        if (inputArea == null) {
            // Set up span to make it look nicer
            inputArea = text.appendChild(document.createElement('span'));
            inputArea.setAttribute("class", "input-area");
            inputArea.setAttribute("id", "inputArea");
        }
        // Reset inside because we need to reset values for the input
        inputArea.innerHTML = "";

        // Date input
        var dateInput = inputArea.appendChild(document.createElement('input'));
        dateInput.setAttribute("id", "auctionDate");
        dateInput.setAttribute("type", "date");
        dateInput.setAttribute("min", formatDateForInput(info['today'])); // Minimum date: today
        dateInput.setAttribute("max", formatDateForInput(info['auction_max_date'])); // Maximum date: 11:59 the night before

        // Time input
        var timeInput = inputArea.appendChild(document.createElement('input'));
        timeInput.setAttribute("id", "auctionTime");
        timeInput.setAttribute("type", "time");
        timeInput.value = "23:59"; // Default to 11:59 PM
    } else if (action == "view_auction") {
        title.innerHTML = "Auction Details";
        text.children[0].innerHTML = "Highest bid: <b>" + formatHTK(info['highest_bid']) + "</b>.";
        text.children[1].innerHTML = "Auction end date: <b>" + formatDate(info['end_date']) + " " + formatTime(info['end_date']) + "</b>.";
        if (info['highest_bid'] == info['ticket_value']) { // Nobody has bid
            text.children[2].innerHTML = "Nobody has bid in this auction. Click <b>Cancel Auction</b> to reclaim your ticket.";
            confirm.innerHTML = "Cancel Auction";
            confirm.setAttribute("style", "background-color: #BB0000;"); // Make button red for dangerous action
        } else {
            confirm.style.display = "none";
            text.children[2].innerHTML = "";
        }
    } else if (action == "execute_auction_owner") {
        title.innerHTML = "Execute Auction";
        text.children[0].innerHTML = "You are executing the auction for your <b>" + info['event_name'] + "</b> ticket.";
        text.children[1].innerHTML = "The ticket will be sent to the highest bidder of the auction.";
        text.children[2].innerHTML = "Click <b>Continue</b> to confirm.";
    } else if (action == "execute_auction_winner") {
        title.innerHTML = "Execute Auction";
        text.children[0].innerHTML = "You are executing the auction for the <b>" + info['event_name'] + "</b> ticket.";
        text.children[1].innerHTML = "The ticket will be sent to you.";
        text.children[2].innerHTML = "Click <b>Continue</b> to confirm.";
    } else if (action == "cancel_auction") {
        title.innerHTML = "Cancel Auction";
        text.children[0].innerHTML = "You are cancelling the auction for your ticket for <b>" + info['event_name'] + "</b>.";
        text.children[1].innerHTML = "The ticket will no longer be available for bids.";
        text.children[2].innerHTML = "Click <b>Cancel Auction</b> to confirm.";
        confirm.innerHTML = "Cancel Auction";
        confirm.setAttribute("style", "background-color: #BB0000;"); // Make button red for dangerous action
    } else if (action == "bid") {
        title.innerHTML = "Add Bid";
        text.children[0].innerHTML = "You are adding a bid on a ticket <b>" + info['event_name'] + "</b>.";
        text.children[1].innerHTML = "The current highest bid is <b>" + formatHTK(info['highest_bid']) + "</b>.";
        text.children[2].innerHTML = "Input how much you would like to bid, and press <b>Continue</b> to submit.";

        var inputArea = body.querySelector("#inputArea");
        if (inputArea == null) {
            // Set up span to make it look nicer
            inputArea = text.appendChild(document.createElement('span'));
            inputArea.setAttribute("class", "input-area");
            inputArea.setAttribute("id", "inputArea");
        }
        // Reset inside because we need to reset values for the input
        inputArea.innerHTML = "";

        // Actual input object
        var input = inputArea.appendChild(document.createElement('input'));
        input.setAttribute("id", "bidAmount");
        input.setAttribute("type", "number");
        input.setAttribute("min", (parseInt(info['highest_bid']) / 100 + 1)); // Minimum is highest bid
        input.setAttribute("max", (parseInt(info['user_balance']))); // Maximum is user's balance
        input.setAttribute("step", 0.01);
        var default_bid = parseInt(info['highest_bid']) / 100 + 1;
        input.setAttribute("placeholder", default_bid);

        // Disable confirm button until user inputs a value
        // confirm.setAttribute("disabled", true);

        // function setEnabled() {
        //     console.log("triggered");
        //     confirm.removeAttribute("disabled");
        // }
        // input.addEventListener("input", setEnabled);

        // Show HTK at the end of input area
        inputArea.innerHTML += " HTK";
    } else if (action == "view") {
        title.innerHTML = "Viewing Ticket";
        text.children[0].innerHTML = "You are viewing the ticket for <b>" + info['event_name'] + "</b> on <b>" + info['event_date'] + "</b>.";
        text.children[1].innerHTML = "<div style='text-align: center;'><img src='" + info['qr_code'] + "' /></div>"
        text.children[2].innerHTML = "This ticket is currently owned by <b>" + info['owner'] + "</b>. If ownership is transfered before the start of the game, the ticket above will no longer be valid.";
        confirm.style.display = "none";
    }


    // On clicking confirm button, make request to execute action
    confirm.onclick = function(event) {
        if (action == "view") {
            closeWindow();
            return;
        }
        // Send necessary information to backend
        if (action == "view_auction") { // Can only click "confirm" button if they are cancelling auction
            action = "cancel_auction";
        }
        var data = {
            action: action,
            user: user,
        };
        // Set up variable information
        if (action == "buy" || action == "enter_lottery" || action == "leave_lottery") {
            data['game_id'] = id;
        } else if (action == "sell" || action == "cancel_auction" || action == "execute_auction_winner" || action == "execute_auction_owner") {
            data['ticket_id'] = id;
        } else if (action == "create_auction") {
            data['ticket_id'] = id;
            data['initial_bid'] = parseInt(info['ticket_value']);
            var endDate = document.getElementById("auctionDate").value;
            var endTime = document.getElementById("auctionTime").value;
            var auctionDate = endDate.split('-').join('') + endTime.split(':').join('');
            data['end_date'] = auctionDate;
        } else if (action == "bid") {
            data['ticket_id'] = id;
            var input = document.getElementById("bidAmount");
            var entered = parseFloat(input.value) || parseFloat(input.placeholder);
            data['bid_amount'] = Math.round(entered * 100);
        }
        console.log(data);

        // Send the request JSON
        $.ajax({
            type: "POST",
            contentType: "application/json",
            data: JSON.stringify(data),
            url: "/requests.pyhtml",
            error: (error) => {
                console.log(error);
                confirm.style.display = "none";
                body.innerHTML = error.responseText;
            },
        }).then((response) => {
            confirm.style.display = "none";

            console.log(response);
            var resp = JSON.parse(response);
            if (resp.hasOwnProperty("error")) { // Action failed
                text.innerHTML = resp.error;
            } else { // Other kind of success
                text.children[0].innerHTML = "Success!";
                if (action == "buy") {
                    text.children[0].innerHTML += " You have bought a ticket for <b>" + info['event_name'] + "</b>.";
                    text.children[1].innerHTML = "Your new balance is <b>" + resp['balance'] + " HTK</b>."
                    text.children[2].innerHTML = "Click <b>Go Back</b> to close this window.";
                } else if (action == "sell") {
                    text.children[0].innerHTML += " You have sold your ticket for <b>" + info['event_name'] + "</b>.";
                    text.children[1].innerHTML = "Your new balance is <b>" + resp['balance'] + " HTK</b>."
                    text.children[2].innerHTML = "Click <b>Go Back</b> to close this window.";
                } else if (action == "enter_lottery") {
                    text.children[0].innerHTML += " You have entered the lottery for <b>" + info['event_name'] + "</b>.";
                    text.children[1].innerHTML = "Check your tickets after the lottery has been executed to see if you won.";
                    text.children[2].innerHTML = "Click <b>Go Back</b> to close this window.";
                } else if (action == "leave_lottery") {
                    text.children[0].innerHTML += " You have left the lottery for <b>" + info['event_name'] + "</b>.";
                    text.children[1].innerHTML = "You will no longer be considered for lottery tickets in this game.";
                    text.children[2].innerHTML = "Click <b>Go Back</b> to close this window.";
                } else if (action == "create_auction") {
                    text.children[0].innerHTML += " Your ticket for <b>" + info['event_name'] + "</b> is now up for auction.";
                    text.children[1].innerHTML = "The auction will end at <b>" + formatDate(data['end_date']) + " " + formatTime(data['end_date']) + "</b>.";
                    text.children[2].innerHTML = "Click <b>Go Back</b> to close this window.";
                    text.removeChild(text.children[3]);
                } else if (action == "execute_auction_owner") {
                    text.children[0].innerHTML += " You have executed the ticket auction.";
                    text.children[1].innerHTML = "The ticket has been sent to the highest bidder.";
                    text.children[2].innerHTML = "Click <b>Go Back</b> to close this window.";
                } else if (action == "execute_auction_winner") {
                    text.children[0].innerHTML += " You have executed the ticket auction.";
                    text.children[1].innerHTML = "You can now find the ticket in the My Tickets page.";
                    text.children[2].innerHTML = "Click <b>Go Back</b> to close this window.";
                } else if (action == "cancel_auction") {
                    text.children[0].innerHTML += " Your ticket for <b>" + info['event_name'] + "</b> is no longer up for auction.";
                    text.children[1].innerHTML = "";
                    text.children[2].innerHTML = "Click <b>Go Back</b> to close this window.";
                } else if (action == "bid") {
                    text.children[0].innerHTML += " You have added a bid for <b>" + info['event_name'] + "</b>.";
                    text.children[1].innerHTML = "The new highest bid is <b>" + formatHTK(data['bid_amount']) + "</b>.";
                    text.children[2].innerHTML = "Click <b>Go Back</b> to close this window.";
                    text.removeChild(text.children[3]);
                }
            }
            if (action == "bid") {
                var gb = document.getElementById("auction_group_box");
                populateListings(user, gb.getAttribute("data-selected"), gb.getAttribute("data-selected-name"));
            }
        });
    };
    modal.scrollIntoView();
}

// Close modal
function closeWindow() {
    var modal = document.getElementById('window');
    modal.style.display = "none";
}

// If a modal is open and the user clicks outside of it, close the modal
window.onclick = function(event) {
    if (event.target.attributes.class && event.target.attributes.class.value == "modal") {
        event.target.style.display = "none";
        location.reload();
    }
}

function populateListings(user, selected, selectedName) {
    document.getElementById("auction_table_select").style.display = "none";
    var gb = document.getElementById("auction_group_box");
    gb.style.display = "block";
    gb.setAttribute("data-selected", selected);
    gb.setAttribute("data-selected-name", selectedName);

    var data = {
        'user': user,
        'action': 'auction_listings',
        'game_id': parseInt(selected),
    };

    // Request the list of auctions from the backend
    $.ajax({
        type: "POST",
        contentType: "application/json",
        data: JSON.stringify(data),
        url: "/requests.pyhtml",
        error: (error) => {
            console.log(error);
            document.write(error.responseText);
        },
    }).then((data) => {
        // Get the list of auctions from the JSON
        var resp = JSON.parse(data);

        // Clear existing data rather than trying to overwrite
        var table = document.getElementById("auctionListings");
        table.innerHTML = "";

        if (resp.hasOwnProperty("Success")) { // && resp.hasOwnProperty("user_balance")) { // Retrieved a list of auctions
            // Need to make a function wrapper to pass in "Add Bid" button function
            function passArguments(user, auction_id, action, info) {
                return function() {
                    openWindow(user, auction_id, action, info);
                };
            }

            for (i in resp['Success']) {
                var auction = resp['Success'][i];
                if (auction.auction_owner != user) { // Don't add a row for this user's auction
                    var row = table.appendChild(document.createElement('tr'));

                    var owner = row.appendChild(document.createElement('td')).appendChild(document.createElement('p'));
                    owner.innerHTML = auction.auction_owner

                    var date = row.appendChild(document.createElement('td'));
                    date.appendChild(document.createElement('p')).innerHTML = formatDate(auction.end_date);
                    date.appendChild(document.createElement('p')).innerHTML = formatTime(auction.end_date);

                    var highestBid = row.appendChild(document.createElement('td')).appendChild(document.createElement('p'));
                    highestBid.innerHTML = formatHTK(auction.highest_bid);
                    if (auction.top_bidder == user) { // This user is the top bidder
                        highestBid.style.color = "#13CE66";
                    }
                    var bidButton = row.appendChild(document.createElement('td')).appendChild(document.createElement('button'));
                    bidButton.setAttribute("class", "actionButton");
                    bidButton.setAttribute("id", "bid" + auction.ticket_id);
                    bidButton.innerHTML = "Add Bid";
                    bidButton.onclick = passArguments(user, auction.ticket_id, 'bid', { 'event_name': selectedName, 'highest_bid': auction.highest_bid, }); // 'user_balance': resp['user_balance'] });
                }
            }
        }
        if (table.innerHTML == "") {
            // Empty table
            var emptyRow = table.appendChild(document.createElement('tr'));
            emptyRow.appendChild(document.createElement('td')).appendChild(document.createElement('p')).innerHTML = "No auctions available.";
            emptyRow.appendChild(document.createElement('td'));
            emptyRow.appendChild(document.createElement('td'));
            emptyRow.appendChild(document.createElement('td'));
        }
    });
}

function auctionGoBack() {
    document.getElementById("auction_table_select").style.display = "table";
    document.getElementById("auction_group_box").style.display = "none";
}

function setupAuctionTabs() {
    var btns = document.getElementById("tabs").children;
    for (var i = 0; i < btns.length; i++) {
        var btn = btns[i];
        (function(i) {
            btn.addEventListener("click", function() {
                for (var j = 0; j < btns.length; j++) {
                    document.getElementById("tab" + (j + 1)).style.display = i == j ? "block" : "none";
                    document.getElementById("tab" + (j + 1) + "-active").classList.toggle("tabbutton-active", i == j)
                }
            })
        })(i);
    }
}