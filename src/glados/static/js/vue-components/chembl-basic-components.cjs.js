'use strict';Object.defineProperty(exports,'__esModule',{value:true});var lib=require('vuetify/lib');//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//

var script = {
  props: {
    links: {
      type: Array,
      default: function () { return []; }
    }
  },
  data: function () { return ({
    isExpanded: false
  }); },
  methods: {
    expandDropdown: function expandDropdown () {
      this.isExpanded = true;
    },
    collapseDropdown: function collapseDropdown () {
      this.isExpanded = false;
    }
  }
};function normalizeComponent(template, style, script, scopeId, isFunctionalTemplate, moduleIdentifier /* server only */, shadowMode, createInjector, createInjectorSSR, createInjectorShadow) {
    if (typeof shadowMode !== 'boolean') {
        createInjectorSSR = createInjector;
        createInjector = shadowMode;
        shadowMode = false;
    }
    // Vue.extend constructor export interop.
    var options = typeof script === 'function' ? script.options : script;
    // render functions
    if (template && template.render) {
        options.render = template.render;
        options.staticRenderFns = template.staticRenderFns;
        options._compiled = true;
        // functional template
        if (isFunctionalTemplate) {
            options.functional = true;
        }
    }
    // scopedId
    if (scopeId) {
        options._scopeId = scopeId;
    }
    var hook;
    if (moduleIdentifier) {
        // server build
        hook = function (context) {
            // 2.3 injection
            context =
                context || // cached call
                    (this.$vnode && this.$vnode.ssrContext) || // stateful
                    (this.parent && this.parent.$vnode && this.parent.$vnode.ssrContext); // functional
            // 2.2 with runInNewContext: true
            if (!context && typeof __VUE_SSR_CONTEXT__ !== 'undefined') {
                context = __VUE_SSR_CONTEXT__;
            }
            // inject component styles
            if (style) {
                style.call(this, createInjectorSSR(context));
            }
            // register component module identifier for async chunk inference
            if (context && context._registeredComponents) {
                context._registeredComponents.add(moduleIdentifier);
            }
        };
        // used by ssr in case component is cached and beforeCreate
        // never gets called
        options._ssrRegister = hook;
    }
    else if (style) {
        hook = shadowMode
            ? function (context) {
                style.call(this, createInjectorShadow(context, this.$root.$options.shadowRoot));
            }
            : function (context) {
                style.call(this, createInjector(context));
            };
    }
    if (hook) {
        if (options.functional) {
            // register for functional component in vue file
            var originalRender = options.render;
            options.render = function renderWithStyleInjection(h, context) {
                hook.call(context);
                return originalRender(h, context);
            };
        }
        else {
            // inject component registration as beforeCreate hook
            var existing = options.beforeCreate;
            options.beforeCreate = existing ? [].concat(existing, hook) : [hook];
        }
    }
    return script;
}var isOldIE = typeof navigator !== 'undefined' &&
    /msie [6-9]\\b/.test(navigator.userAgent.toLowerCase());
function createInjector(context) {
    return function (id, style) { return addStyle(id, style); };
}
var HEAD;
var styles = {};
function addStyle(id, css) {
    var group = isOldIE ? css.media || 'default' : id;
    var style = styles[group] || (styles[group] = { ids: new Set(), styles: [] });
    if (!style.ids.has(id)) {
        style.ids.add(id);
        var code = css.source;
        if (css.map) {
            // https://developer.chrome.com/devtools/docs/javascript-debugging
            // this makes source maps inside style tags work properly in Chrome
            code += '\n/*# sourceURL=' + css.map.sources[0] + ' */';
            // http://stackoverflow.com/a/26603875
            code +=
                '\n/*# sourceMappingURL=data:application/json;base64,' +
                    btoa(unescape(encodeURIComponent(JSON.stringify(css.map)))) +
                    ' */';
        }
        if (!style.element) {
            style.element = document.createElement('style');
            style.element.type = 'text/css';
            if (css.media)
                { style.element.setAttribute('media', css.media); }
            if (HEAD === undefined) {
                HEAD = document.head || document.getElementsByTagName('head')[0];
            }
            HEAD.appendChild(style.element);
        }
        if ('styleSheet' in style.element) {
            style.styles.push(code);
            style.element.styleSheet.cssText = style.styles
                .filter(Boolean)
                .join('\n');
        }
        else {
            var index = style.ids.size - 1;
            var textNode = document.createTextNode(code);
            var nodes = style.element.childNodes;
            if (nodes[index])
                { style.element.removeChild(nodes[index]); }
            if (nodes.length)
                { style.element.insertBefore(textNode, nodes[index]); }
            else
                { style.element.appendChild(textNode); }
        }
    }
}/* script */
var __vue_script__ = script;

/* template */
var __vue_render__ = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;return _c('li',{staticClass:"nav-link dropdown-container",on:{"mouseover":_vm.expandDropdown,"mouseout":_vm.collapseDropdown}},[_c('a',[_vm._v("More")]),_vm._v(" "),_c('ul',{staticClass:"dropdown-list",class:{ expanded: _vm.isExpanded, collapsed: !_vm.isExpanded}},_vm._l((_vm.links),function(link){return _c('li',{key:link.label,staticClass:"dropdown-link"},[_c('a',{attrs:{"href":link.url}},[_vm._v(_vm._s(link.label))])])}),0)])};
var __vue_staticRenderFns__ = [];

  /* style */
  var __vue_inject_styles__ = function (inject) {
    if (!inject) { return }
    inject("data-v-607769a8_0", { source: "@font-face{font-family:ChEMBL_Verdana;src:local(Verdana),url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana.otf);src:url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana.eot?#iefix) format(\"embedded-opentype\"),url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana.woff) format(\"woff\"),url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana.ttf) format(\"truetype\"),url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana.svg) format(\"svg\");font-weight:400;font-style:normal}@font-face{font-family:ChEMBL_Verdana_Bold;src:local(Verdana Bold),url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana-Bold.eot);src:url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana-Bold.eot?#iefix) format(\"embedded-opentype\"),url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana-Bold.woff) format(\"woff\"),url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana-Bold.ttf) format(\"truetype\"),url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana-Bold.svg) format(\"svg\");font-weight:700}@font-face{font-family:ChEMBL_HelveticaNeueLTPRo;src:local(Verdana Bold),url(https://www.ebi.ac.uk/chembl/static/font/helvetica/helveticaneueltprolt.eot);src:url(https://www.ebi.ac.uk/chembl/static/font/helvetica/helveticaneueltprolt.eot?#iefix) format(\"embedded-opentype\"),url(https://www.ebi.ac.uk/chembl/static/font/helvetica/helveticaneueltprolt.woff) format(\"woff\"),url(https://www.ebi.ac.uk/chembl/static/font/helvetica/helveticaneueltprolt.ttf) format(\"truetype\"),url(https://www.ebi.ac.uk/chembl/static/font/helvetica/helveticaneueltprolt.svg) format(\"svg\"),url(https://www.ebi.ac.uk/chembl/static/font/helvetica/helveticaneueltprolt.otf) format(\"otf\")}.chembl-font[data-v-607769a8]{font-family:ChEMBL_HelveticaNeueLTPRo,helvetica,Arial,sans-serif}.helvetica-font[data-v-607769a8]{font-family:helvetica,Arial,sans-serif}.verdana-font[data-v-607769a8]{font-family:ChEMBL_Verdana,Verdana,sans-serif}.verdana-bold-font[data-v-607769a8]{font-family:ChEMBL_Verdana_Bold,Verdana,sans-serif}.chembl-teal[data-v-607769a8]{background-color:#09979b}.lighter-teal[data-v-607769a8]{background-color:#62b7bd}.dropdown-container[data-v-607769a8]{position:relative}.dropdown-container .dropdown-list[data-v-607769a8]{position:absolute;left:0;top:100%;background-color:#09979b;list-style-type:none}.dropdown-container .dropdown-list .dropdown-link[data-v-607769a8]{padding:5px 20px;white-space:nowrap}.dropdown-container .dropdown-list .dropdown-link[data-v-607769a8]:first-child{border-top:1px solid #62b7bd}.dropdown-container .dropdown-list .dropdown-link[data-v-607769a8]:not(:last-child){border-bottom:1px solid #62b7bd}.dropdown-container .dropdown-list .dropdown-link a[data-v-607769a8]:active,.dropdown-container .dropdown-list .dropdown-link a[data-v-607769a8]:link,.dropdown-container .dropdown-list .dropdown-link a[data-v-607769a8]:visited{color:#fff;text-decoration:none}.dropdown-container .dropdown-list .dropdown-link[data-v-607769a8]:hover{background-color:#62b7bd;cursor:pointer}.dropdown-container .dropdown-list.collapsed[data-v-607769a8]{visibility:hidden;opacity:0;transition:.2s ease}.dropdown-container .dropdown-list.expanded[data-v-607769a8]{visibility:visible;opacity:1;transition:.2s ease}", map: undefined, media: undefined });

  };
  /* scoped */
  var __vue_scope_id__ = "data-v-607769a8";
  /* module identifier */
  var __vue_module_identifier__ = undefined;
  /* functional template */
  var __vue_is_functional_template__ = false;
  /* style inject SSR */
  
  /* style inject shadow dom */
  

  
  var __vue_component__ = /*#__PURE__*/normalizeComponent(
    { render: __vue_render__, staticRenderFns: __vue_staticRenderFns__ },
    __vue_inject_styles__,
    __vue_script__,
    __vue_scope_id__,
    __vue_is_functional_template__,
    __vue_module_identifier__,
    false,
    createInjector,
    undefined,
    undefined
  );//


var ScreenTypes = {
  SMALL: 'SMALL',
  MEDIUM: 'MEDIUM',
  LARGE: 'LARGE'
};

var script$1 = {
  name: 'ChEMBLMasthead',
  components: {
    VContainer: lib.VContainer,
    VCol: lib.VCol,
    VRow: lib.VRow,
    MastheadDropdown: __vue_component__
  },
  props: {
    serviceName: {
      type: String,
      default: 'Service Name'
    },
    links: {
      type: Array,
      default: function () {
        var defaultLinks = [];
        for (var i = 0; i < 20; i++) {
          defaultLinks.push({label: ("link-" + i), url:'/'});
        }
        return defaultLinks
      }
    }
  },
  data: function () { return ({
    screenType: ScreenTypes.LARGE,
    screenWidth: 0,
    visibleLinks: [],
    additionalLinks: []
  }); },
  beforeDestroy: function beforeDestroy () {
    if (typeof window !== 'undefined') {
      // Remove the resize event when the component is destroyed
      window.removeEventListener('resize', this.onResize, { passive: true });
    }
  },
  mounted: function mounted () {
    // Check which is the current type of screen
    this.onResize();
    // Create resize event to check for the type of screen
    window.addEventListener('resize', this.onResize, { passive: true });
  },
  methods: {
    onResize: function onResize () {
      // it is not necessary to create more types for extra large screens for now. 
      this.screenWidth = window.innerWidth;
      if (window.innerWidth < 600){
        this.screenType = ScreenTypes.SMALL;
      } else if (window.innerWidth < 992) {
        this.screenType = ScreenTypes.MEDIUM;
      } else {
        this.screenType = ScreenTypes.LARGE;
      }
      this.setupLinksLayout();
    },
    setupLinksLayout: function setupLinksLayout () {
      var visibleLinksContainer = this.$refs.visibleLinks;
      var moreLinkWidth = 78;
      var avaiableWidth = visibleLinksContainer.clientWidth - moreLinkWidth;
      var visibleLinksMustBe = [];
      var additionalLinksMustBe = [];
      for (var i = 0; i < this.links.length; i++) {
        var currentLink = this.links[i];
        var currentLabel = currentLink.label;
        var charWidth = 8.7; // A guess of the average character width
        var padding = 40; // 20 left + 20 right 
        var border = 1;
        var predictedWidth = Math.ceil(currentLabel.length * charWidth + padding + border);
        if (predictedWidth < avaiableWidth) {
          visibleLinksMustBe.push(currentLink);
          avaiableWidth = avaiableWidth - predictedWidth;
        } else {
          additionalLinksMustBe.push(currentLink);
        }
      }
      this.visibleLinks = visibleLinksMustBe;
      this.additionalLinks = additionalLinksMustBe;
    }
  }
};/* script */
var __vue_script__$1 = script$1;

/* template */
var __vue_render__$1 = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;return _c('div',{staticClass:"chembl-masthead"},[_c('v-container',{staticClass:"masthead-content"},[_c('v-row',[_c('v-col',{attrs:{"cols":"1"}},[_vm._t("logo")],2),_vm._v(" "),_c('v-col',{attrs:{"cols":"5"}},[_c('div',{staticClass:"service-name-container"},[_c('div',{staticClass:"service-name-text"},[_vm._v("\n            "+_vm._s(_vm.serviceName)+"\n          ")])])]),_vm._v(" "),_c('v-col',{attrs:{"cols":"6"}},[_vm._t("search-bar")],2)],1),_vm._v(" "),_c('v-row',[_c('v-col',{ref:"visibleLinks",staticClass:"links-container",attrs:{"cols":"8"}},[_c('ul',[_vm._l((_vm.visibleLinks),function(link){return _c('li',{key:link.label,staticClass:"nav-link"},[_c('a',{attrs:{"href":link.url}},[_vm._v(_vm._s(link.label))])])}),_vm._v(" "),(_vm.additionalLinks.length > 0)?_c('MastheadDropdown',{attrs:{"links":_vm.additionalLinks}}):_vm._e()],2)]),_vm._v(" "),_c('v-col',{staticClass:"links-container",attrs:{"cols":"2","offset":"2"}},[_vm._t("action-button")],2)],1)],1)],1)};
var __vue_staticRenderFns__$1 = [];

  /* style */
  var __vue_inject_styles__$1 = function (inject) {
    if (!inject) { return }
    inject("data-v-4bbf2f44_0", { source: "@font-face{font-family:ChEMBL_Verdana;src:local(Verdana),url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana.otf);src:url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana.eot?#iefix) format(\"embedded-opentype\"),url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana.woff) format(\"woff\"),url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana.ttf) format(\"truetype\"),url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana.svg) format(\"svg\");font-weight:400;font-style:normal}@font-face{font-family:ChEMBL_Verdana_Bold;src:local(Verdana Bold),url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana-Bold.eot);src:url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana-Bold.eot?#iefix) format(\"embedded-opentype\"),url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana-Bold.woff) format(\"woff\"),url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana-Bold.ttf) format(\"truetype\"),url(https://www.ebi.ac.uk/chembl/static/font/verdana/Verdana-Bold.svg) format(\"svg\");font-weight:700}@font-face{font-family:ChEMBL_HelveticaNeueLTPRo;src:local(Verdana Bold),url(https://www.ebi.ac.uk/chembl/static/font/helvetica/helveticaneueltprolt.eot);src:url(https://www.ebi.ac.uk/chembl/static/font/helvetica/helveticaneueltprolt.eot?#iefix) format(\"embedded-opentype\"),url(https://www.ebi.ac.uk/chembl/static/font/helvetica/helveticaneueltprolt.woff) format(\"woff\"),url(https://www.ebi.ac.uk/chembl/static/font/helvetica/helveticaneueltprolt.ttf) format(\"truetype\"),url(https://www.ebi.ac.uk/chembl/static/font/helvetica/helveticaneueltprolt.svg) format(\"svg\"),url(https://www.ebi.ac.uk/chembl/static/font/helvetica/helveticaneueltprolt.otf) format(\"otf\")}.chembl-font[data-v-4bbf2f44]{font-family:ChEMBL_HelveticaNeueLTPRo,helvetica,Arial,sans-serif}.helvetica-font[data-v-4bbf2f44]{font-family:helvetica,Arial,sans-serif}.verdana-font[data-v-4bbf2f44]{font-family:ChEMBL_Verdana,Verdana,sans-serif}.verdana-bold-font[data-v-4bbf2f44]{font-family:ChEMBL_Verdana_Bold,Verdana,sans-serif}.chembl-teal[data-v-4bbf2f44]{background-color:#09979b}.lighter-teal[data-v-4bbf2f44]{background-color:#62b7bd}.chembl-masthead[data-v-4bbf2f44]{background-color:#09979b}.chembl-masthead .masthead-content[data-v-4bbf2f44]{padding-bottom:0}.chembl-masthead .service-name-container[data-v-4bbf2f44]{color:#fff;font-size:50px;height:100%;display:flex;justify-content:flex-end;flex-direction:column}.chembl-masthead .service-name-container .service-name-text[data-v-4bbf2f44]{font-family:ChEMBL_HelveticaNeueLTPRo,helvetica,Arial,sans-serif}.chembl-masthead .links-container[data-v-4bbf2f44]{font-family:ChEMBL_Verdana,Verdana,sans-serif;color:#fff;padding-bottom:0}.chembl-masthead .links-container ul[data-v-4bbf2f44]{list-style-type:none;display:flex}.chembl-masthead .links-container .nav-link[data-v-4bbf2f44]{padding:5px 20px;font-size:.8em;letter-spacing:.1em;line-height:1.5;border-right:1px solid #fff}.chembl-masthead .links-container .nav-link a[data-v-4bbf2f44]{display:block}.chembl-masthead .links-container .nav-link a[data-v-4bbf2f44]:active,.chembl-masthead .links-container .nav-link a[data-v-4bbf2f44]:link,.chembl-masthead .links-container .nav-link a[data-v-4bbf2f44]:visited{color:#fff;text-decoration:none}.chembl-masthead .links-container .nav-link[data-v-4bbf2f44]:hover{background-color:#62b7bd;cursor:pointer}", map: undefined, media: undefined });

  };
  /* scoped */
  var __vue_scope_id__$1 = "data-v-4bbf2f44";
  /* module identifier */
  var __vue_module_identifier__$1 = undefined;
  /* functional template */
  var __vue_is_functional_template__$1 = false;
  /* style inject SSR */
  
  /* style inject shadow dom */
  

  
  var __vue_component__$1 = /*#__PURE__*/normalizeComponent(
    { render: __vue_render__$1, staticRenderFns: __vue_staticRenderFns__$1 },
    __vue_inject_styles__$1,
    __vue_script__$1,
    __vue_scope_id__$1,
    __vue_is_functional_template__$1,
    __vue_module_identifier__$1,
    false,
    createInjector,
    undefined,
    undefined
  );//
//
//
//
//
//

var script$2 = {};/* script */
var __vue_script__$2 = script$2;

/* template */
var __vue_render__$2 = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;return _c('div',[_vm._v("\n  This is the Marvin Sketcher!!!\n")])};
var __vue_staticRenderFns__$2 = [];

  /* style */
  var __vue_inject_styles__$2 = undefined;
  /* scoped */
  var __vue_scope_id__$2 = undefined;
  /* module identifier */
  var __vue_module_identifier__$2 = undefined;
  /* functional template */
  var __vue_is_functional_template__$2 = false;
  /* style inject */
  
  /* style inject SSR */
  
  /* style inject shadow dom */
  

  
  var __vue_component__$2 = /*#__PURE__*/normalizeComponent(
    { render: __vue_render__$2, staticRenderFns: __vue_staticRenderFns__$2 },
    __vue_inject_styles__$2,
    __vue_script__$2,
    __vue_scope_id__$2,
    __vue_is_functional_template__$2,
    __vue_module_identifier__$2,
    false,
    undefined,
    undefined,
    undefined
  );//
//
//
//
//
//

var script$3 = {};/* script */
var __vue_script__$3 = script$3;

/* template */
var __vue_render__$3 = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;return _c('div',[_vm._v("\n  This is the Search by IDs Menu!!!\n")])};
var __vue_staticRenderFns__$3 = [];

  /* style */
  var __vue_inject_styles__$3 = undefined;
  /* scoped */
  var __vue_scope_id__$3 = undefined;
  /* module identifier */
  var __vue_module_identifier__$3 = undefined;
  /* functional template */
  var __vue_is_functional_template__$3 = false;
  /* style inject */
  
  /* style inject SSR */
  
  /* style inject shadow dom */
  

  
  var __vue_component__$3 = /*#__PURE__*/normalizeComponent(
    { render: __vue_render__$3, staticRenderFns: __vue_staticRenderFns__$3 },
    __vue_inject_styles__$3,
    __vue_script__$3,
    __vue_scope_id__$3,
    __vue_is_functional_template__$3,
    __vue_module_identifier__$3,
    false,
    undefined,
    undefined,
    undefined
  );var components=/*#__PURE__*/Object.freeze({__proto__:null,ChEMBLMasthead: __vue_component__$1,MarvinSketcher: __vue_component__$2,SearchByIDsMenu: __vue_component__$3});// Import vue components

// install function executed by Vue.use()
function install(Vue) {
  if (install.installed) { return; }
  install.installed = true;
  Object.keys(components).forEach(function (componentName) {
    Vue.component(componentName, components[componentName]);
  });
}

// Create module definition for Vue.use()
var plugin = {
  install: install,
};

// To auto-install when vue is found
/* global window global */
var GlobalVue = null;
if (typeof window !== 'undefined') {
  GlobalVue = window.Vue;
} else if (typeof global !== 'undefined') {
  GlobalVue = global.Vue;
}
if (GlobalVue) {
  GlobalVue.use(plugin);
}exports.ChEMBLMasthead=__vue_component__$1;exports.MarvinSketcher=__vue_component__$2;exports.SearchByIDsMenu=__vue_component__$3;exports.default=plugin;