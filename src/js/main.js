require('babel-polyfill')
require('classlist-polyfill')
import reqwest from 'reqwest'

const config = require('./config.json')

const $weatherBtn = document.querySelector('.weather-btn'),
	  $zipcodeInput = document.querySelector('.zipcode'),
	  $weather = document.querySelector('.weather')

$weatherBtn.addEventListener('click', () => {
	const zipcode = $zipcodeInput.value,
	      request = `${config.API_URL}${zipcode},us&units=imperial&appid=${config.API_KEY}`

	reqwest({
		url: request,
		method: 'get',
		type: 'jsonp',
		error: (err) => {
			console.error(err)
		},
		success: (resp) => {
			$weather.classList.remove('hide')
			setBackgroundImage(resp.weather[0].main.toLowerCase())

			$weather.innerHTML = `
				<div class="temperature">
					<span></span>
					${Math.floor(resp.main.temp)}&deg;F
				</div>`
			console.info(resp)
		},
	})
})

let setBackgroundImage = (weatherDesc) => {
	$weather.style.backgroundImage = `url('img/${weatherDesc}.jpg')`
}