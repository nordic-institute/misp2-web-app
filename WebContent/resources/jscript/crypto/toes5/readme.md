# Babel and webpack for compiling javascript to ie11 compatible

## How to use
 * Make required changes to ```./src/mispcryto.js```  
 * Install [nodejs](https://nodejs.org/en/) if not yet installed
 * Run commad ```npm install``` if it is a first time
 * Run command ```npm run build```
 * Resulting file is placed in ```../mispcryto.min.js```
 

## Config
 * [.browserslistrc](https://github.com/browserslist/browserslist) - lists what browsers to support
 * [package.json](https://docs.npmjs.com/creating-a-package-json-file) - node.js configuration
 * [.babelrc](https://babeljs.io/docs/en/config-files) - babel configuration. Babel compiles javascript to compatible version of javascript
 * [webpack.config.js](https://webpack.js.org/configuration/) - webpack configuration. Webpack bundles javascript into a single file and minifies it
 