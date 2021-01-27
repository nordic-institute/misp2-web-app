const path = require('path');

module.exports = {
	mode: 'production',
	entry: './src/mispcrypto.js',
	output: {
		filename: 'mispcryto.min.js',
		path: path.resolve(__dirname, '../')
	},
	module: {
		rules: [{
			test: /\.js$/,
			exclude: /node_modules/,
			use: {
				loader: 'babel-loader',
			}
		}]
	},
};