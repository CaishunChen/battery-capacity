httpRequest = function (url, callback) {
	var http = new XMLHttpRequest();
	http.onreadystatechange = function () {
		callback(http);
	};

	http.open("GET", url);
	http.send();
};
		
getBatteryIndex = function (type, callback) {
	httpRequest("data/" + type + "/index.csv", function (http) {
		if (http.readyState === 4) {
			if (http.status === 200) {
				csv = http.responseText.split("\n");
				index = [];

				for (var i = 0; i < csv.length; i++) {
					if (i == 0) {
						continue;
					}

					row = csv[i].split(",");
					index.push({
						"show": Boolean(Number(row[0])),
						"brand": row[1],
						"model": row[2],
						"voltage": Number(row[3]),
						"exp_capacity": Number(row[4]),
						"current": Number(row[5]),
						"type": row[6],
						"cutoff": Number(row[7]),
						"file": row[8],
						"comment": row[9]
					});
				}

				callback(index);
			}
		}
	});
};

getBatteryData = function (type, index, callback) {
	batteries = [];
	requests = [];

	for (var i = 0; i < index.length; i++) {
		battery = index[i];

		if (battery["show"]) {
			// TODO: Copy the index object and add the data to it and return that.
			httpRequest("data/" + type + "/" + battery["file"], function (http) {
				if (http.readyState === 4) {
					if (http.status === 200) {
						csv = http.responseText.split("\n");
						dp = [];

						for (var j = 0; j < csv.length; j++) {
							if (csv[j][2] < battery["cutoff"]) {
								break;
							}

							dp.push([ battery["current"] * (j / 3600), csv[j][2] ]);
						}

						batteries.push(dp);
					}
				}
			});
		}
	}

	$.when().then(function () {
		callback(batteries);
	});
};

drawChart = function () {
	getBatteryIndex("9V", function (index) {
		console.log(index);
		getBatteryData("9V", index, function (batteries) {
			console.log(batteries);
		});
	});

	var data = google.visualization.arrayToDataTable([
			['Year', 'Sales', 'Expenses'],
          ['2004',  1000,      400],
          ['2005',  1170,      460],
          ['2006',  660,       1120],
          ['2007',  1030,      540]
        ]);

	var options = {
		title: "Battery Capacity",  // TODO: Put the battery type and shit like that here.
	};

	var chart = new google.visualization.LineChart(document.getElementById('chart'));
	chart.draw(data, options);
};

google.setOnLoadCallback(drawChart);

