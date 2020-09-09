alert('HERE')
console.log('GOING TO IMPORT')

console.log('EbiBasicComponents: ', EbiBasicComponents)

// import * as EbiBasicComponents from "{% static 'js/vue_components/components_source/ebi-basic-components.cjs.js' %}"


Vue.component("ebiheader", EbiBasicComponents.EBIHeader);

glados.useNameSpace('glados.VueComponents.EBIHeader', {
    load: function () {
        alert('LOAD HEADER')
        const vueApp = new Vue({
            el: "#glados-ebi-header",
            data: {
                display: "redbox"
            }
        });
    }
})