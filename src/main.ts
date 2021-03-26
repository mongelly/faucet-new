import '../static/css/ps2.css';
import 'nes.css/css/nes.css';
import Vue from 'vue';
import App from './App.vue';
import { VueReCaptcha } from 'vue-recaptcha-v3';
import VueAnalytics from 'vue-analytics';
import { Connex } from '@vechain/connex';

Vue.use(VueReCaptcha, {
  siteKey: '6LfL1-kZAAAAAC1vhX-YvGyw8S2gG6Y-KlrLn1Bi',
  loaderOptions: {
    useRecaptchaNet: true,
  },
});

const connex = new Connex({node: 'https://testnet.veblocks.net', network: 'test'});
const faucetScAddr = '0xf5bae8079c294b65dafe28f21acd4f627572cf40';


declare module 'vue/types/vue' {
  interface Vue {
    $connex: Connex;
    $faucetScAddr: string;
  }
}

Vue.prototype.$connex = connex;
Vue.prototype.$faucetScAddr = faucetScAddr;

Vue.use(VueAnalytics, {
  id: 'UA-132391998-2',
  disabled: process.env.NODE_ENV !== 'production',
});
Vue.config.productionTip = false;

new Vue({
  render: (h) => h(App),
}).$mount('#app');
