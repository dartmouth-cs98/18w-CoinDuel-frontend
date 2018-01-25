#!/usr/bin/env python
print "Content-Type: text/html\n\n"

"""
Get Cryptocurrency Prices

Author:		Josh Kerber
Date:		24 January 2018
Description:	Get prices of all cryptocurrencies on CoinMarketCap exchange
"""

import os
import json
import time
import cgi

def makeRequest(req, out):
	"""make request and return response"""
	# execute request
	cmd = '{} > {}'.format(req, out)
	os.system(cmd)

	# wait for response
	while not os.path.isfile(out):
		time.sleep(0.5)

	# read response
	f = open(out)
	text = f.read()
	f.close()

	# discard record
	os.system('rm -f {}'.format(out))
	return json.loads(text)

def main():
	"""retrieve current prices of cryptos"""
	# get all price data
	priceRes = makeRequest(
		'curl https://api.coinmarketcap.com/v1/ticker/?limit=0', 
		'allPrices.txt')

	# load param symbol
	param = None
	fs = cgi.FieldStorage()
	for key in fs.keys():
		if str(key) == 'symbol':
			param = fs[key].value
			print('<TITLE>{} Price</TITLE>'.format(param))
			break
	if not param:
		print('<TITLE>Cryptocurrency Prices</TITLE>')

	# parse data
	allPrices = []
	for item in priceRes:
		symbol = item['symbol']
		if param and symbol != param:
			continue

		# append price
		try:
			price = float(item['price_usd'])
		except TypeError:
			price = item['price_usd']

		# instantiate data point
		dataPoint = {
			'symbol': symbol,
			'name': item['name'],
			'price_USD': price}
		allPrices.append(dataPoint)

	# sort / clean up price list
	priceObj = {
		'UTC':time.time(),
		'exchange':'https://coinmarketcap.com/'}
	if not allPrices:
		priceObj['error'] = 'coin \'{}\' not found'.format(param)
	else:
		sortedPrices = sorted(allPrices, key=lambda item: item['symbol'])
		priceObj['results'] = sortedPrices
	
	# render price string
	print('<pre>{}</pre>'.format(json.dumps(priceObj, indent=4, separators=(',', ': '))))

if __name__ == "__main__":
	main()
