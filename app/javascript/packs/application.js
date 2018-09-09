/* eslint no-console:0 */
import './stylesheets/application.scss';

import Vue from 'vue/dist/vue'
import Buefy from 'buefy';
import VueResource from 'vue-resource'
import App from './components/app.vue'

Vue.use(Buefy);
Vue.use(VueResource);

document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(document.createElement('app'));

  new Vue({
    el: 'app',
    template: '<App/>',
    components: { App }
  });
});
