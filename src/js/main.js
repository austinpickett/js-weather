require('babel-polyfill')
import raf from 'raf'

async function test() {
	const response = await fetch('test.json')
	return response.json()
}

test().then(resp => {
	console.log(resp)
})