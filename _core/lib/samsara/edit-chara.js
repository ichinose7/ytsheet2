"use strict";

window.onload = function () {
    calcStt();
    calcKarma();
    calcSubStt();
    calcCashbook();
};

function formCheck() {
    if (document.sheet.characterName.value === '' && document.sheet.aka.value === '') {
        alert('キャラクター名か地球での氏名のいずれかを入力してください。');
        return false;
    }
    if (document.sheet.protect && document.sheet.protect.value === 'password' && document.sheet.pass && document.sheet.pass.value === '') {
        alert('パスワードが入力されていません。');
        return false;
    }
    return true;
}

// 能力値計算
function calcStt() {
    const stats = ['Body', 'Mind', 'Sense', 'Intellect'];

    stats.forEach(stat => {
        const skillCheat = Number(document.sheet[`stt${stat}SkillCheat`]?.value || 0);
        const race = Number(document.sheet[`stt${stat}Race`]?.value || 0);
        const growth = Number(document.sheet[`stt${stat}Growth`]?.value || 0);

        const total = skillCheat + race + growth;
        let successRate = total * 5;
        if (successRate > 99) successRate = 99;

        const totalView = document.getElementById(`stt-${stat.toLowerCase()}-total`);
        const sucView = document.getElementById(`suc-${stat.toLowerCase()}-view`);

        if (totalView) totalView.innerHTML = total;
        if (sucView) sucView.innerHTML = successRate;
    });

    calcSubStt();
}

// 副能力値計算
function calcSubStt() {
    const sttBody = Number(document.getElementById('stt-body-total')?.innerHTML || 0);
    const sttMind = Number(document.getElementById('stt-mind-total')?.innerHTML || 0);
    const sttSense = Number(document.getElementById('stt-sense-total')?.innerHTML || 0);
    const sttIntellect = Number(document.getElementById('stt-intellect-total')?.innerHTML || 0);

    // HP: 基本値=(身体+精神)×3 + 補正値
    const hpBase = (sttBody + sttMind) * 3;
    const hpMod = Number(document.sheet.hpMod?.value || 0);
    const hpTotal = hpBase + hpMod;
    document.getElementById('hp-base-view').innerHTML = hpBase;
    document.getElementById('hp-total-view').innerHTML = hpTotal;

    // 限界重量: 身体×2 + 補正値
    const weightLimitBase = sttBody * 2;
    const weightLimitMod = Number(document.sheet.weightLimitMod?.value || 0);
    const weightLimit = weightLimitBase + weightLimitMod;
    document.getElementById('weight-limit-base-view').innerHTML = weightLimitBase;
    document.getElementById('weight-limit-total-view').innerHTML = weightLimit;

    const weightHeld = Number(document.sheet.weightHeld?.value || 0);
    const overWeight = Math.max(0, weightHeld - weightLimit);

    // AP: 基本値=(感覚+知性) + 補正値 - 超過重量
    const apBase = sttSense + sttIntellect;
    const apMod = Number(document.sheet.apMod?.value || 0);
    const apTotal = apBase + apMod - overWeight;
    document.getElementById('ap-base-view').innerHTML = apBase;
    document.getElementById('ap-total-view').innerHTML = apTotal;

    // 装甲値 = 装備中の装備品の装甲合計
    let defenseTotal = 0;
    const equipNum = Number(document.sheet.equipNum?.value || 0);
    for (let i = 1; i <= equipNum; i++) {
        const equippedField = document.sheet[`equip${i}Equipped`];
        const defenseField = document.sheet[`equip${i}Defense`];
        if (equippedField && equippedField.checked && defenseField) {
            defenseTotal += Number(defenseField.value || 0);
        }
    }
    document.getElementById('defense-total-view').innerHTML = defenseTotal;

    // 部隊値 = フォロワーの部隊値合計
    let troopTotal = 0;
    const followerNum = Number(document.sheet.followerNum?.value || 0);
    for (let i = 1; i <= followerNum; i++) {
        const troopField = document.sheet[`follower${i}Troop`];
        if (troopField) troopTotal += Number(troopField.value || 0);
    }
    document.getElementById('troop-total-view').innerHTML = troopTotal;
}

// カルマ計算（限界強度は切り上げ）
function calcKarma() {
    let karmaInside = Number(document.sheet.karmaInside?.value || 0);
    let karmaUsed = 0;

    const stats = ['Body', 'Mind', 'Sense', 'Intellect'];
    stats.forEach(stat => {
        karmaUsed += Number(document.sheet[`stt${stat}Race`]?.value || 0);
        karmaUsed += Number(document.sheet[`stt${stat}Growth`]?.value || 0);
    });

    const cheatNum = Number(document.sheet.cheatNum?.value || 0);
    for (let i = 1; i <= cheatNum; i++) {
        karmaUsed += Number(document.sheet[`cheat${i}Karma`]?.value || 0);
    }

    const carrierNum = Number(document.sheet.carrierNum?.value || 0);
    for (let i = 1; i <= carrierNum; i++) {
        karmaUsed += Number(document.sheet[`carrier${i}Karma`]?.value || 0);
    }

    const equipNum = Number(document.sheet.equipNum?.value || 0);
    for (let i = 1; i <= equipNum; i++) {
        karmaUsed += Number(document.sheet[`equip${i}Karma`]?.value || 0);
    }

    const historyNum = Number(document.sheet.historyNum?.value || 0);
    for (let i = 1; i <= historyNum; i++) {
        karmaInside += Number(document.sheet[`history${i}Karma`]?.value || 0);
    }

    const karmaLatent = karmaInside - karmaUsed;
    // 限界強度は切り上げ
    const karmaLimit = Math.ceil(karmaLatent / 5);

    document.getElementById('karma-used-view').innerHTML = karmaUsed;
    document.getElementById('karma-latent-view').innerHTML = karmaLatent;
    document.getElementById('karma-limit-view').innerHTML = karmaLimit;
}

// 収支履歴計算
function calcCashbook() {
    let balance = 0;
    const cashbookNum = Number(document.sheet.cashbookNum?.value || 0);
    for (let i = 1; i <= cashbookNum; i++) {
        const income = Number(document.sheet[`cashbook${i}Income`]?.value || 0);
        const expense = Number(document.sheet[`cashbook${i}Expense`]?.value || 0);
        balance = balance + income - expense;
        const balanceView = document.getElementById(`cashbook${i}Balance`);
        if (balanceView) balanceView.innerHTML = balance;
    }
}

// イラ言語追加/削除
function addLangIra() {
    const num = Number(document.sheet.langIraNum?.value || 0) + 1;
    const container = document.getElementById('lang-ira-container');
    const template = document.getElementById('lang-ira-template').content;
    const clone = document.importNode(template, true);
    clone.querySelectorAll('[name]').forEach(elm => elm.name = elm.name.replace(/TMPL/g, num));
    clone.querySelectorAll('[id]').forEach(elm => elm.id = elm.id.replace(/TMPL/g, num));
    container.appendChild(clone);
    document.sheet.langIraNum.value = num;
}
function delLangIra() {
    const num = Number(document.sheet.langIraNum?.value || 0);
    if (num > 1) { document.getElementById('lang-ira-row' + num)?.remove(); document.sheet.langIraNum.value = num - 1; }
}

// 地球言語追加/削除
function addLangEarth() {
    const num = Number(document.sheet.langEarthNum?.value || 0) + 1;
    const container = document.getElementById('lang-earth-container');
    const template = document.getElementById('lang-earth-template').content;
    const clone = document.importNode(template, true);
    clone.querySelectorAll('[name]').forEach(elm => elm.name = elm.name.replace(/TMPL/g, num));
    clone.querySelectorAll('[id]').forEach(elm => elm.id = elm.id.replace(/TMPL/g, num));
    container.appendChild(clone);
    document.sheet.langEarthNum.value = num;
}
function delLangEarth() {
    const num = Number(document.sheet.langEarthNum?.value || 0);
    if (num > 1) { document.getElementById('lang-earth-row' + num)?.remove(); document.sheet.langEarthNum.value = num - 1; }
}

// 行追加/削除関数
function addCheat() {
    const num = Number(document.sheet.cheatNum.value) + 1;
    const table = document.getElementById('cheat-table').querySelector('tbody');
    const template = document.getElementById('cheat-template').content;
    const clone = document.importNode(template, true);
    clone.querySelector('tr').id = 'cheat-row' + num;
    clone.querySelectorAll('[name]').forEach(elm => elm.name = elm.name.replace(/TMPL/g, num));
    clone.querySelectorAll('[id]').forEach(elm => elm.id = elm.id.replace(/TMPL/g, num));
    table.appendChild(clone);
    document.sheet.cheatNum.value = num;
}
function delCheat() { const num = Number(document.sheet.cheatNum.value); if (num > 1) { document.getElementById('cheat-row' + num)?.remove(); document.sheet.cheatNum.value = num - 1; } }

function addCarrier() {
    const num = Number(document.sheet.carrierNum.value) + 1;
    const table = document.getElementById('carrier-table').querySelector('tbody');
    const template = document.getElementById('carrier-template').content;
    const clone = document.importNode(template, true);
    clone.querySelector('tr').id = 'carrier-row' + num;
    clone.querySelectorAll('[name]').forEach(elm => elm.name = elm.name.replace(/TMPL/g, num));
    clone.querySelectorAll('[id]').forEach(elm => elm.id = elm.id.replace(/TMPL/g, num));
    table.appendChild(clone);
    document.sheet.carrierNum.value = num;
}
function delCarrier() { const num = Number(document.sheet.carrierNum.value); if (num > 1) { document.getElementById('carrier-row' + num)?.remove(); document.sheet.carrierNum.value = num - 1; } }

function addEquip() {
    const num = Number(document.sheet.equipNum.value) + 1;
    const table = document.getElementById('equip-table').querySelector('tbody');
    const template = document.getElementById('equip-template').content;
    const clone = document.importNode(template, true);
    clone.querySelector('tr').id = 'equip-row' + num;
    clone.querySelectorAll('[name]').forEach(elm => elm.name = elm.name.replace(/TMPL/g, num));
    clone.querySelectorAll('[id]').forEach(elm => elm.id = elm.id.replace(/TMPL/g, num));
    table.appendChild(clone);
    document.sheet.equipNum.value = num;
}
function delEquip() { const num = Number(document.sheet.equipNum.value); if (num > 1) { document.getElementById('equip-row' + num)?.remove(); document.sheet.equipNum.value = num - 1; calcSubStt(); } }

function addTool() {
    const num = Number(document.sheet.toolNum.value) + 1;
    const table = document.getElementById('tool-table').querySelector('tbody');
    const template = document.getElementById('tool-template').content;
    const clone = document.importNode(template, true);
    clone.querySelector('tr').id = 'tool-row' + num;
    clone.querySelectorAll('[name]').forEach(elm => elm.name = elm.name.replace(/TMPL/g, num));
    clone.querySelectorAll('[id]').forEach(elm => elm.id = elm.id.replace(/TMPL/g, num));
    table.appendChild(clone);
    document.sheet.toolNum.value = num;
}
function delTool() { const num = Number(document.sheet.toolNum.value); if (num > 1) { document.getElementById('tool-row' + num)?.remove(); document.sheet.toolNum.value = num - 1; } }

function addFollower() {
    const num = Number(document.sheet.followerNum.value) + 1;
    const table = document.getElementById('follower-table').querySelector('tbody');
    const template = document.getElementById('follower-template').content;
    const clone = document.importNode(template, true);
    clone.querySelector('tr').id = 'follower-row' + num;
    clone.querySelectorAll('[name]').forEach(elm => elm.name = elm.name.replace(/TMPL/g, num));
    clone.querySelectorAll('[id]').forEach(elm => elm.id = elm.id.replace(/TMPL/g, num));
    table.appendChild(clone);
    document.sheet.followerNum.value = num;
}
function delFollower() { const num = Number(document.sheet.followerNum.value); if (num > 1) { document.getElementById('follower-row' + num)?.remove(); document.sheet.followerNum.value = num - 1; calcSubStt(); } }

function addHistory() {
    const num = Number(document.sheet.historyNum.value) + 1;
    const table = document.getElementById('history-table').querySelector('tbody');
    const template = document.getElementById('history-template').content;
    const clone = document.importNode(template, true);
    clone.querySelector('tr').id = 'history-row' + num;
    clone.querySelectorAll('[name]').forEach(elm => elm.name = elm.name.replace(/TMPL/g, num));
    clone.querySelectorAll('[id]').forEach(elm => elm.id = elm.id.replace(/TMPL/g, num));
    table.appendChild(clone);
    document.sheet.historyNum.value = num;
}
function delHistory() { const num = Number(document.sheet.historyNum.value); if (num > 1) { document.getElementById('history-row' + num)?.remove(); document.sheet.historyNum.value = num - 1; } }

function addCashbook() {
    const num = Number(document.sheet.cashbookNum.value) + 1;
    const table = document.getElementById('cashbook-table').querySelector('tbody');
    const template = document.getElementById('cashbook-template').content;
    const clone = document.importNode(template, true);
    clone.querySelector('tr').id = 'cashbook-row' + num;
    clone.querySelectorAll('[name]').forEach(elm => elm.name = elm.name.replace(/TMPL/g, num));
    clone.querySelectorAll('[id]').forEach(elm => elm.id = elm.id.replace(/TMPL/g, num));
    table.appendChild(clone);
    document.sheet.cashbookNum.value = num;
    calcCashbook();
}
function delCashbook() { const num = Number(document.sheet.cashbookNum.value); if (num > 1) { document.getElementById('cashbook-row' + num)?.remove(); document.sheet.cashbookNum.value = num - 1; calcCashbook(); } }
