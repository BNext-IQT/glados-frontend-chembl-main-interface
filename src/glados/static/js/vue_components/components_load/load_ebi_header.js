
alert('HERE')
console.log('GOING TO IMPORT')

console.log('EbiBasicComponents: ', EbiBasicComponents)

// import * as EbiBasicComponents from "{% static 'js/vue_components/components_source/ebi-basic-components.cjs.js' %}"

glados.useNameSpace('glados.VueComponents.EBIHeader', {
    load: function () {
        alert('LOAD HEADER')
    }
})