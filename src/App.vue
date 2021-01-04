<template>
    <div id="app">
        <PageHead v-if="isTestNet"/>
        <section
            v-if="!isTestNet"
            class="nes-container with-title"
        >Faucet is only available in testnet.</section>
        <section v-if="isTestNet" class="form nes-container" style="text-align: center">
            <div v-if="step === status.confirm.step" class="nes-field">
                <p>AH!!!</p>
                <p>its you !!! let me see what I can find for you !</p>
            </div>

            <div class="step-2" v-if="step === status.ask.step">
                <a @click="reset" href="javascript:;" class="frame-close">
                    <i class="nes-icon close"></i>
                </a>
                <div class="nes-field">
                    <p>Well...well...well...... My mom doesn't let me talk to stranger..... Unless you tell me who you are</p>
                </div>
                <div class="nes-field">
                    <button @click="signTx" class="nes-btn">It's me!!!</button>
                </div>
            </div>

            <div v-if="step === status.tryAgain.step">
                <div class="nes-field">
                    <p>It seems something wrong here</p>
                </div>
                <div class="nes-field">
                    <button @click="signTx" class="nes-btn">Try again</button>
                </div>
            </div>

            <div v-if="step === status.reAsk.step">
                <div class="nes-field">
                    <p>The certificate is expired, I am not sure who you are...</p>
                </div>
                <div class="nes-field">
                    <button @click="signTx" class="nes-btn">It's me!!!</button>
                </div>
            </div>

            <div v-if="step === status.outOfLimitL.step">
                <div class="nes-field">
                    <p>Greed is good! BUT save some for others! Come back tomorrow.</p>
                </div>
            </div>

            <div
                v-if="step === status.insufficient.step"
            >Unfortunately I unable to give you some coins to explore because I do not have sufficient balance. Please come back later and try again!</div>

            <div class="step-5" v-if="step === status.success.step">
                <a @click="reset" href="javascript:;" class="frame-close">
                    <i class="nes-icon close"></i>
                </a>
                <div class="nes-field">
                    <p>
                        I found this!!! TXID:
                        <a
                            :href="`https://insight.vecha.in/#/txs/${txid}`"
                            target="_blank"
                        >{{shortTxid}}</a>, good luck on your journey!!
                    </p>
                    <button @click="reset" class="nes-btn">See you soon!</button>
                </div>
            </div>

            <form v-if="step === status.start.step" @submit.prevent="signTx">
                <div class="nes-field">
                    <p>Welcome to the VeChain world, I think you need some tokens to explore the world</p>
                </div>
                <div class="nes-field">
                    <button type="submit" class="nes-btn is-primary">Claim Tokens</button>
                </div>
            </form>
        </section>
        <PageFoot/>
    </div>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';
import PageHead from './components/PageHead.vue';
import PageFoot from './components/PageFoot.vue';
import status from './status';

@Component({
    components: {
        PageHead,
        PageFoot,
    },
})
export default class App extends Vue {
    public address = '';
    public loading = false;
    public msg = '';
    public isSuccess = false;
    public status = status;
    public step = this.status.start.step;
    private syncReleaseUrl = `https://github.com/vechain/thor-sync.electron/releases`;
    private txid = '';
    private respError = '';

    private isTestNet = true;

    private claimABI = {
    constant: false,
    inputs: [],
    name: 'claim',
    outputs: [],
    payable: false,
    stateMutability: 'nonpayable',
    type: 'function',
    };

    private getDelegatorABI = {
    constant: true,
    inputs: [],
    name: 'getDelegator',
    outputs: [
      {
        name: '',
        type: 'address',
      },
    ],
    payable: false,
    stateMutability: 'view',
    type: 'function',
    };


    private feedelegatorAPI = 'https://omg.outofgas.io:28050/sign';
    private authorizationID = 'c164997a-e4e9-4b06-8242-c4389328704e';

    private delegatorAddr: string = '';

    public async created() {
        this.$ga.page('/faucet');
        this.isTestNet = await this.checkNet();
        if (this.isTestNet)  {
            const faucetSC =  this.$connex.thor.account(this.$faucetScAddr);
            const abiMethod = await faucetSC.method(this.getDelegatorABI);
            const output = await abiMethod.call();
            this.delegatorAddr = (output.decoded as any)[0];
        }
    }

    public openSync() {
        const customProtocolDetection = require('custom-protocol-detection');
        const vechainAppUrl = 'vechain-app:///' + encodeURIComponent(window.location.href);
        const gotoDownload = () => {
            window.location.href = this.syncReleaseUrl;
        };
        customProtocolDetection(vechainAppUrl, () => {
            gotoDownload();
        }, () => {
            // TODO Open with sync
        }, () => {
            gotoDownload();
        });
    }

    get shortTxid() {
        return !this.txid ? '' : this.txid.substr(0, 6) + '......' + this.txid.substr(60, 66);
    }

    public async checkNet() {
        const block = this.$connex.thor.block(0);
        const firstBlock = await block.get();
        return firstBlock!.id === '0x000000000b2bce3c70bc649a02749e8687721b09ed2e15997f466536b20bb127';
    }

    public reset() {
        this.step = this.status.start.step;
    }

    public async signTx() {
        const claimMethod = this.$connex.thor.account(this.$faucetScAddr).method(this.claimABI);
        const clause = claimMethod.asClause();
        const msg: Connex.Vendor.TxMessage = [
            clause,
        ];
        const token = await this.$recaptcha('claim');
        const urlApi = this.feedelegatorAPI + '?' + `authorization=${this.authorizationID}&recaptcha=${token}`;

        const signingService = this.$connex.vendor.sign('tx', msg);
        signingService
        .gas(100000)
        .delegate(urlApi, this.delegatorAddr)
        .request()
        .then((result) => {
            this.txid = result.txid,
            this.step = status.success.step;
        }).catch((err) => {
            this.step = this.status.tryAgain.step;
        });
    }
}
</script>

<style>
html,
body {
    width: 100%;
    padding: 0;
    margin: 0;
    height: 100%;
    position: relative;
    line-height: 30px;
}
#app {
    /* -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    margin-top: 60px; */
    position: absolute;
    top: -100px;
    left: 0;
    right: 0;
    bottom: 0;
    /* padding: 40px 80px; */
    margin: auto;
    width: 80%;
    height: 200px;
}
.actions {
    text-align: right;
    margin-top: 20px;
}
.step-2,
.step-5 {
    padding-top: 30px;
}
.frame-close {
    position: absolute;
    top: -44px;
    right: 2px;
    display: flex;
    padding: 5px;
    border: 4px solid #000;
    border-radius: 3px;
}

.frame-close:hover .nes-icon.close::before {
    color: white;
}
.frame-close:hover {
    color: white;
    background-color: black;
}
.sync-link:hover,
.sync-link {
    color: rgb(124, 195, 35);
    text-decoration: none;
    font-size: 24px;
}
@media (min-width: 800px) {
    #app {
        padding: 0 40px;
        width: 90%;
    }
}

@media (min-width: 1200px) {
    #app {
        width: 70%;
    }
}

@media (min-width: 1440px) {
    #app {
        width: 60%;
    }
}
</style>

