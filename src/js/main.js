require('babel-polyfill')
import reqwest from 'reqwest'

const config = require('./config.json')

console.log(config.API_URL)

const $weatherBtn = document.querySelector('.weather-btn'),
	  $zipcodeInput = document.querySelector('.zipcode'),
	  $weather = document.querySelector('.weather')

$weatherBtn.addEventListener('click', () => {
	const zipcode = $zipcodeInput.value,
	      request = `${config.API_URL}${zipcode}&units=imperial&appid=${config.API_KEY}`

	reqwest({
		url: request,
		method: 'get',
		type: 'jsonp',
		error: function(err) {
			console.error(err)
		},
		success: function(resp) {
			$weather.innerHTML = resp.main.temp
		},
	})
})