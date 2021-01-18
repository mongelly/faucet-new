<template>
    <header class="page-header">
        <div class="balance">
            <span>Faucet VET:</span>
            <span>{{vet}}</span>
        </div>
        <div class="balance">
            <span>Faucet VTHO:</span>
            <span>{{vtho}}</span>
        </div>
        <div class="balance">
            <span>Delegator VTHO:</span>
            <span>{{delegatorvtho}}</span>
        </div>
    </header>
</template>
<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';

@Component
export default class PageHeader extends Vue {
    public balance = '0x0';
    public energy = '0x0';
    public delegatorenergy = '0x0';
    private faucetSC = this.$connex.thor.account(this.$faucetScAddr);
    private delegatorAddr: string = '';

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

    get vet() {
        const result = parseInt(this.balance, 16) / 1e18;

        return Math.round(result).toLocaleString();
    }

    get vtho() {
        const result = parseInt(this.energy, 16) / 1e18;

        return Math.round(result).toLocaleString();
    }

    get delegatorvtho() {
        const result = parseInt(this.delegatorenergy, 16) / 1e18;

        return Math.round(result).toLocaleString();
    }

    public async setBalance() {
        const theAccount = await this.faucetSC.get();
        this.balance = theAccount.balance;
        this.energy = theAccount.energy;
    }

    public async setDelegatorBalance() {
        if (this.delegatorAddr !== '0x0000000000000000000000000000000000000000') {
            const delegator = this.$connex.thor.account(this.delegatorAddr);
            this.delegatorenergy = (await delegator.get()).energy;
        } else {
            this.delegatorenergy = '0x00';
        }
    }

    public async created() {
        const abiMethod = await this.faucetSC.method(this.getDelegatorABI);
        const output = await abiMethod.call();
        this.delegatorAddr = (output.decoded as any)[0];

        this.setBalance();
        this.setDelegatorBalance();
        const ticker = this.$connex.thor.ticker();
        for (; ;) {
            await ticker.next();
            await this.setBalance();
            await this.setDelegatorBalance();
        }
    }
}
</script>

<style>
.page-header {
    position: fixed;
    top: 0;
    width: 100%;
    left: 0;
    padding: 10px 20px;
}
.balance {
    display: flex;
}
.balance span:first-of-type {
    width: 250px;
    padding-right: 10px;
    text-align: right;
}
.balance span:last-of-type {
    width: 220px;
    text-align: right;
}
</style>
