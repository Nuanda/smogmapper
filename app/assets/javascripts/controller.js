var heatmapLayer;
var map;

var baseLayer;

var cfg = {
	"radius": .025,
	"maxOpacity": .6,
	"scaleRadius": true,
	"useLocalRadius": true,
	"latField": 'x',
	"lngField": 'y',
	"valueField": 'value'
};

function retrieveData(){
    var latitudes = new Array();
    var longtitudes = new Array();
    var values = new Array();
    for(var i = 0; i < 500; i++){
        latitudes[i] = Math.random()*(20.256446-19.786780) + 19.786780;
        longtitudes[i] = Math.random()*(50.126177-49.968323) + 49.968323;
        values[i] = Math.random()*300 +
                    100*(Math.min(latitudes[i]-19.786780, 20.256446-latitudes[i]))/(20.256446-19.786780) +
                    100*(Math.min(longtitudes[i]-49.968323, 50.126177-longtitudes[i]))/(50.126177-49.968323);
    }
    var result = new Object();
    result.max = 500;
    var data = new Array();
    for(var i = 0; i<500; i++){
        var dp = new Object();
        dp.x = longtitudes[i];
        dp.y = latitudes[i];
        dp.value = values[i];
        data[i] = dp;
    }
    result.data = data;
    return result;

	/*var result = new Object();
	result.max = 500;
	result.data = new Array();
	for(var i=0; i<300; i++){
		var dataPoint = new Object();
		dataPoint.x = Math.random()*650;
		dataPoint.y = Math.random()*450;
		dataPoint.value = Math.random()*500;
		result.data[i] = dataPoint;
	}
	return result; /*{
		max: 500,
		data: [
			{x: 10, y: 15, value: 300},
			{x: 10, y: 25, value: 300},
			{x: 10, y: 35, value: 300},
			{x: 10, y: 55, value: 300},
			{x: 120, y: 15, value: 150},
			{x: 100, y: 150, value: 500}
		]
	};*/
}


function setData(){
	heatMap.setData(retrieveData());
}

function init(){
	heatmapLayer = new HeatmapOverlay(cfg);
	
	//baseLayer = L.tileLayer(
	//	'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{
	//		attribution: '',
	//		maxZoom: 18
	//	}
	//);

	//map = new L.map('map', {
	//	center: new L.LatLng(50.0525, 19.9659),
	//	zoom: 11,
	//	layers: [baseLayer, heatmapLayer]
	//});

	heatmapLayer.setData(retrieveData());
	//window.setInterval(setData, 1000);
}
