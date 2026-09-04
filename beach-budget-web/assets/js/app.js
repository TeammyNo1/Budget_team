/* ============================================================
   Beach Budget Web — ตรรกะทั้งหมดของหน้าเว็บ
   ไม่มี framework ไม่มี build step  เปิดผ่าน static host ได้เลย
   ============================================================ */
'use strict';

/* ---------- 1. หมวดหมู่ ---------- */
const CATS = {
  rent:      {n:'ค่าเช่าที่พัก', i:'🏠', c:'var(--c1)'},
  electric:  {n:'ค่าไฟ',        i:'⚡', c:'var(--c2)'},
  water:     {n:'ค่าน้ำ',       i:'💧', c:'var(--c10)'},
  internet:  {n:'อินเทอร์เน็ต',  i:'🛜', c:'var(--c7)'},
  phone:     {n:'ค่าโทรศัพท์',   i:'📱', c:'var(--c6)'},
  transport: {n:'เดินทาง',      i:'⛽', c:'var(--c4)'},
  food:      {n:'ค่ากิน',       i:'🍜', c:'var(--c3)'},
  groceries: {n:'ของเข้าบ้าน',   i:'🛒', c:'var(--c9)'},
  supplies:  {n:'ของใช้',       i:'🧴', c:'var(--c9)'},
  laundry:   {n:'ซักรีด',       i:'🧺', c:'var(--c6)'},
  health:    {n:'สุขภาพ',       i:'💊', c:'var(--c8)'},
  fitness:   {n:'ฟิตเนส',       i:'🏋️', c:'var(--c5)'},
  insurance: {n:'ประกัน',       i:'🛡️', c:'var(--c7)'},
  fun:       {n:'เที่ยว/บันเทิง', i:'🏖️', c:'var(--c5)'},
  shopping:  {n:'ช้อปปิ้ง',      i:'🛍️', c:'var(--c8)'},
  debt:      {n:'จ่ายหนี้',      i:'🤝', c:'var(--c7)'},
  saving:    {n:'เก็บออม',      i:'🐖', c:'var(--c2)'},
  other_expense:{n:'อื่น ๆ',     i:'📌', c:'var(--c10)'},

  salary:    {n:'เงินเดือน',     i:'💰', c:'var(--c5)'},
  freelance: {n:'ฟรีแลนซ์',      i:'💻', c:'var(--c1)'},
  bonus:     {n:'โบนัส',        i:'🎁', c:'var(--c4)'},
  dividend:  {n:'ปันผล/ดอกเบี้ย',i:'📈', c:'var(--c2)'},
  refund:    {n:'ได้เงินคืน',    i:'↩️', c:'var(--c10)'},
  other_income:{n:'อื่น ๆ',      i:'📌', c:'var(--c10)'},
};
const EXPENSE_CATS = ['rent','electric','water','internet','phone','transport','food','groceries','supplies','laundry','health','fitness','insurance','fun','shopping','debt','saving','other_expense'];
const INCOME_CATS  = ['salary','freelance','bonus','dividend','refund','other_income'];
const cat = id => CATS[id] || CATS.other_expense;

/* ---------- 2. ไอคอนเมนู ---------- */
const ICON = {
  home:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10.5 12 3l9 7.5"/><path d="M5 9.8V20h14V9.8"/><path d="M9.5 20v-5.5h5V20"/></svg>',
  list:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><path d="M8 6h12M8 12h12M8 18h12M3.5 6h.01M3.5 12h.01M3.5 18h.01"/></svg>',
  plan:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3a9 9 0 1 0 9 9h-9V3Z"/><path d="M15 3.5A9 9 0 0 1 20.5 9H15V3.5Z"/></svg>',
  debt:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="m11 17 2 2 3-3"/><path d="M3 8.5 7 5l5 3 5-3 4 3.5-4 4-3-2v6H10v-6l-3 2-4-4Z"/></svg>',
  cog:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3.2"/><path d="M12 2.8v2.4M12 18.8v2.4M4.5 12H2.1M21.9 12h-2.4M6.7 6.7 5 5M19 19l-1.7-1.7M6.7 17.3 5 19M19 5l-1.7 1.7"/></svg>',
  search:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>',
  plus:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>',
  sun:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M2 12h2M20 12h2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/></svg>',
  moon:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 14.5A8.5 8.5 0 0 1 9.5 4a8.5 8.5 0 1 0 10.5 10.5Z"/></svg>',
  reset:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3.5 12a8.5 8.5 0 1 0 2.6-6.1"/><path d="M3.5 4.5V10H9"/></svg>',
  menu:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 7h16M4 12h16M4 17h16"/></svg>',
  x:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg>',
};

/* ---------- 3. ตัวช่วยตัวเลข / วันที่ ---------- */
const nf  = new Intl.NumberFormat('th-TH',{maximumFractionDigits:2});
const nf0 = new Intl.NumberFormat('th-TH',{maximumFractionDigits:0});
const money  = v => nf.format(Math.round(v*100)/100);
const money0 = v => nf0.format(v);
const baht   = v => '฿' + money(v);
const kbaht  = v => Math.abs(v) >= 10000 ? '฿' + nf0.format(Math.round(v/1000)) + 'k' : '฿' + nf0.format(v);
const dfmt = (d,o) => new Intl.DateTimeFormat('th-TH',o).format(d);

const iso   = d => `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
const parse = s => new Date(s.slice(0,10) + 'T00:00:00');
const esc   = s => String(s ?? '').replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));

/** ช่วงเวลาแบบ [start, end) */
function makeRange(period, anchor){
  const a = new Date(anchor.getFullYear(), anchor.getMonth(), anchor.getDate());
  let s, e;
  switch(period){
    case 'day':   s = a; e = new Date(a); e.setDate(e.getDate()+1); break;
    case 'week':  s = new Date(a); s.setDate(a.getDate() - ((a.getDay()+6)%7));
                  e = new Date(s); e.setDate(s.getDate()+7); break;
    case 'year':  s = new Date(a.getFullYear(),0,1); e = new Date(a.getFullYear()+1,0,1); break;
    default:      s = new Date(a.getFullYear(),a.getMonth(),1);
                  e = new Date(a.getFullYear(),a.getMonth()+1,1); period='month';
  }
  return {period, start:s, end:e};
}
function shiftRange(r,n){
  const a = new Date(r.start);
  if(r.period==='day')       a.setDate(a.getDate()+n);
  else if(r.period==='week') a.setDate(a.getDate()+7*n);
  else if(r.period==='year') a.setFullYear(a.getFullYear()+n);
  else                       a.setMonth(a.getMonth()+n);
  return makeRange(r.period,a);
}
function rangeLabel(r){
  if(r.period==='day')   return dfmt(r.start,{day:'numeric',month:'long',year:'numeric'});
  if(r.period==='month') return dfmt(r.start,{month:'long',year:'numeric'});
  if(r.period==='year')  return 'ปี ' + dfmt(r.start,{year:'numeric'});
  const last = new Date(r.end); last.setDate(last.getDate()-1);
  return dfmt(r.start,{day:'numeric',month:'short'}) + ' – ' + dfmt(last,{day:'numeric',month:'short',year:'numeric'});
}
const inRange = (r,dateStr) => { const d = parse(dateStr); return d >= r.start && d < r.end; };

/** นับวันทำงาน (จ–ศ) กับวันหยุดในช่วง */
function dayCount(r){
  let work = 0, total = 0;
  for(const d = new Date(r.start); d < r.end; d.setDate(d.getDate()+1)){
    total++; if(d.getDay() >= 1 && d.getDay() <= 5) work++;
  }
  return {work, holiday: total-work, total};
}
/** ผ่านไปแล้วกี่ส่วนของช่วงนี้ (0–1) */
function elapsed(r, now){
  if(now <= r.start) return 0;
  if(now >= r.end)   return 1;
  return (now - r.start) / (r.end - r.start);
}

/* ---------- 4. สถานะ ---------- */
const STORE_KEY = 'beachbudget.web.v1';
let SEED = null;
let DATA = null;
let TODAY = new Date();

const S = {
  page:'home',
  range:null,
  filterType:'all',
  filterCat:null,
  query:'',
  sort:'date',
  editing:null,   // ร่างของฟอร์มเพิ่ม/แก้ไข
  detail:null,    // id ของรายการที่กำลังดู
};

const save   = () => { try{ localStorage.setItem(STORE_KEY, JSON.stringify(DATA)); }catch(e){} };
const wipe   = () => { try{ localStorage.removeItem(STORE_KEY); }catch(e){} };

/* ---------- 5. สูตรคำนวณ ---------- */
const allTx    = () => DATA.transactions;
const inWindow = () => allTx().filter(t => inRange(S.range, t.date));
const sumBy    = (list,type) => list.filter(t=>t.type===type).reduce((a,t)=>a+t.amount,0);
const debtOf   = id => DATA.debts.find(d=>d.id===id);
const left     = d => Math.max(0, d.principal - d.paid);

const netIncome    = () => Math.max(0, DATA.settings.salary - DATA.settings.socialSecurity - DATA.settings.otherDeduction);
const linesTotal   = () => DATA.settings.lines.reduce((a,l)=>a+l.amount,0);
const debtPlan     = () => DATA.debts.filter(d=>left(d)>0).reduce((a,d)=>a+(d.monthlyPlan||0),0);
const foodBudget   = r => { const c = dayCount(r), s = DATA.settings; return c.work*s.foodWorkday + c.holiday*s.foodHoliday; };
const thisMonth    = () => makeRange('month', TODAY);
const planTotal    = () => linesTotal() + foodBudget(thisMonth()) + debtPlan();

/** รายจ่ายแยกหมวด เรียงมาก→น้อย */
function byCategory(list){
  const m = new Map();
  list.filter(t=>t.type==='expense').forEach(t => m.set(t.categoryId, (m.get(t.categoryId)||0) + t.amount));
  return [...m.entries()].sort((a,b)=>b[1]-a[1]);
}

/* ---------- 6. กราฟ ---------- */
/** โดนัทสัดส่วนรายจ่าย */
function donutSvg(entries, total){
  if(!entries.length || total <= 0)
    return `<div class="empty"><div class="big">🌊</div>ยังไม่มีรายจ่ายในช่วงนี้</div>`;
  const R = 62, SW = 22, C = 2*Math.PI*R;
  // รวมหมวดที่เล็กกว่าอันดับ 7 เป็นชิ้น "อื่น ๆ" ชิ้นเดียว วงจะได้อ่านง่าย
  const TOP = 7;
  const tail = entries.slice(TOP).reduce((a,e)=>a+e[1],0);
  const slices = tail > 0
    ? [...entries.slice(0,TOP), ['__rest', tail]]
    : entries.slice(0,TOP);
  let acc = 0;
  const arcs = slices.map(([id,v]) => {
    const len = v/total*C;
    const gap = slices.length > 1 ? 2.5 : 0;
    const color = id === '__rest' ? 'var(--ink-faint)' : cat(id).c;
    const name  = id === '__rest' ? 'หมวดอื่น ๆ รวมกัน' : cat(id).n;
    const el = `<circle cx="80" cy="80" r="${R}" fill="none" stroke="${color}" stroke-width="${SW}"
      stroke-dasharray="${Math.max(0,len-gap).toFixed(2)} ${(C-len+gap).toFixed(2)}"
      stroke-dashoffset="${(-acc).toFixed(2)}" transform="rotate(-90 80 80)"><title>${esc(name)}: ${baht(v)}</title></circle>`;
    acc += len; return el;
  }).join('');
  const rows = entries.slice(0,TOP).map(([id,v]) =>
    `<div class="row"><span class="sw" style="background:${cat(id).c}"></span>
      <span class="nm">${cat(id).i} ${esc(cat(id).n)}</span>
      <span class="vl num">${money0(v)}</span>
      <span class="pc num">${(v/total*100).toFixed(0)}%</span></div>`).join('');
  const more = tail > 0
    ? `<div class="row" style="color:var(--ink-soft)"><span class="sw" style="background:var(--ink-faint)"></span>
       <span class="nm">อีก ${entries.length-TOP} หมวดรวมกัน</span>
       <span class="vl num">${money0(tail)}</span>
       <span class="pc num">${(tail/total*100).toFixed(0)}%</span></div>` : '';
  return `<div class="donutwrap">
    <svg class="chart" viewBox="0 0 160 160" width="176" height="176" role="img" aria-label="สัดส่วนรายจ่ายแยกตามหมวด รวม ${money0(total)} บาท">
      <circle cx="80" cy="80" r="${R}" fill="none" stroke="var(--line-soft)" stroke-width="${SW}"/>
      ${arcs}
      <text x="80" y="75" text-anchor="middle" font-size="10" fill="var(--ink-soft)">รวมรายจ่าย</text>
      <text x="80" y="93" text-anchor="middle" font-size="19" font-weight="700" fill="var(--ink)" font-family="Bai Jamjuree">${money0(total)}</text>
    </svg>
    <div class="legend" style="width:100%">${rows}${more}</div>
  </div>`;
}

/** กราฟแท่ง — รายวัน (หรือรายเดือนเมื่อดูรายปี) */
function barsSvg(){
  const buckets = [];
  if(S.range.period === 'year'){
    for(let m=0;m<12;m++){
      const v = allTx().filter(t=>t.type==='expense' && parse(t.date).getFullYear()===S.range.start.getFullYear() && parse(t.date).getMonth()===m)
                       .reduce((a,t)=>a+t.amount,0);
      buckets.push({l: dfmt(new Date(S.range.start.getFullYear(),m,1),{month:'short'}), v});
    }
  }else{
    let from = S.range.start, to = S.range.end;
    if(S.range.period === 'day'){ from = new Date(S.range.start); from.setDate(from.getDate()-13); }
    for(const d = new Date(from); d < to; d.setDate(d.getDate()+1)){
      const k = iso(d);
      const v = allTx().filter(t=>t.type==='expense' && t.date.slice(0,10)===k).reduce((a,t)=>a+t.amount,0);
      buckets.push({l: S.range.period==='month' ? String(d.getDate()) : dfmt(d,{weekday:'short'}), v, k});
    }
  }
  const max = Math.max(...buckets.map(b=>b.v), 0);
  if(max <= 0) return `<div class="empty"><div class="big">📊</div>ยังไม่มีรายจ่ายในช่วงนี้</div>`;

  // ปัดเพดานขึ้นให้เป็นเลขกลม ๆ เพื่อให้ป้ายแกนอ่านง่าย
  const pow = Math.pow(10, Math.floor(Math.log10(max)));
  const top = Math.ceil(max/(pow/2))*(pow/2);

  const W=760, H=240, padL=52, padR=8, padT=12, padB=28;
  const pw = W-padL-padR, ph = H-padT-padB;
  const step = pw/buckets.length;
  const bw = Math.max(3, Math.min(26, step-4));

  const ticks = [0, top/2, top].map(v=>{
    const y = padT + ph - v/top*ph;
    return `<line x1="${padL}" x2="${W-padR}" y1="${y.toFixed(1)}" y2="${y.toFixed(1)}" stroke="var(--line-soft)" stroke-width="1"/>
      <text x="${padL-8}" y="${(y+4).toFixed(1)}" text-anchor="end" font-size="11" fill="var(--ink-faint)">${kbaht(v).replace('฿','')}</text>`;
  }).join('');

  const every = buckets.length > 16 ? Math.ceil(buckets.length/10) : 1;
  const bars = buckets.map((b,i)=>{
    const h = b.v/top*ph, x = padL + i*step + (step-bw)/2, y = padT + ph - h;
    const label = (i % every === 0)
      ? `<text x="${(x+bw/2).toFixed(1)}" y="${H-9}" text-anchor="middle" font-size="11" fill="var(--ink-faint)">${b.l}</text>` : '';
    const rect = h > 0
      ? `<rect x="${x.toFixed(1)}" y="${y.toFixed(1)}" width="${bw.toFixed(1)}" height="${h.toFixed(1)}"
           rx="${Math.min(5,bw/2).toFixed(1)}" fill="url(#seaGrad)"><title>${b.l}: ${baht(b.v)}</title></rect>` : '';
    return rect + label;
  }).join('');

  return `<svg class="chart" viewBox="0 0 ${W} ${H}" role="img" aria-label="รายจ่ายราย${S.range.period==='year'?'เดือน':'วัน'} สูงสุด ${money0(max)} บาท">
    <defs><linearGradient id="seaGrad" x1="0" y1="1" x2="0" y2="0">
      <stop offset="0%" stop-color="var(--sea)"/><stop offset="100%" stop-color="var(--lagoon)"/>
    </linearGradient></defs>
    ${ticks}${bars}
  </svg>`;
}

/* ---------- 7. ชิ้นส่วนที่ใช้ซ้ำ ---------- */
function txRows(list, withDaySeparator){
  let html = '', lastDay = null;
  for(const t of list){
    const day = t.date.slice(0,10);
    if(withDaySeparator && day !== lastDay){
      const dayTx = list.filter(x=>x.date.slice(0,10)===day);
      const net = dayTx.reduce((a,x)=>a + (x.type==='income'? x.amount : -x.amount), 0);
      html += `<tr class="daysep"><td colspan="4">${
        day===iso(TODAY) ? 'วันนี้' : dfmt(parse(day),{weekday:'long',day:'numeric',month:'long'})}</td>
        <td class="daysep r" style="text-align:right">${net>=0?'+':'−'}${money(Math.abs(net))}</td></tr>`;
      lastDay = day;
    }
    const c = cat(t.categoryId), inc = t.type==='income';
    html += `<tr data-tx="${t.id}" tabindex="0">
      <td><div class="cellcat"><span class="dot" style="background:color-mix(in srgb,${c.c} 16%,transparent);color:${c.c}">${c.i}</span>
        <span class="nm">${esc(c.n)}</span></div></td>
      <td class="note">${esc(t.note||'—')} ${t.slip?'<span class="slipmark" title="แนบสลิป">🧾</span>':''}</td>
      <td style="color:var(--ink-soft);white-space:nowrap">${dfmt(parse(t.date),{day:'numeric',month:'short'})}</td>
      <td>${t.debtId && debtOf(t.debtId) ? `<span class="pill info">${esc(debtOf(t.debtId).name)}</span>` : ''}</td>
      <td class="r amt ${inc?'in':'out'}"><span class="num">${inc?'+':'−'}${money(t.amount)}</span></td>
    </tr>`;
  }
  return html;
}

const tableShell = body => `<div class="tablewrap"><table class="tx">
  <thead><tr><th>หมวดหมู่</th><th>รายละเอียด</th><th>วันที่</th><th>หนี้</th><th class="r">จำนวนเงิน</th></tr></thead>
  <tbody>${body}</tbody></table></div>`;

/* ---------- 8. หน้า: ภาพรวม ---------- */
function pageHome(){
  const list = inWindow();
  const income = sumBy(list,'income'), expense = sumBy(list,'expense');
  const entries = byCategory(list);
  const mr = thisMonth();
  const monthTx = allTx().filter(t=>inRange(mr,t.date));
  const monthSpent = sumBy(monthTx,'expense');
  const budget = planTotal();
  const el = elapsed(mr, TODAY);
  const daysLeft = Math.max(1, Math.ceil((mr.end - TODAY)/86400000));
  const remain = budget - monthSpent;
  const savedThisMonth = sumBy(monthTx,'income') - monthSpent;
  const debtLeft = DATA.debts.reduce((a,d)=>a+left(d),0);
  const fb = foodBudget(S.range), fs = list.filter(t=>t.categoryId==='food').reduce((a,t)=>a+t.amount,0);

  const ratio = budget ? monthSpent/budget : 0;
  const status = ratio > 1 ? {c:'bad', t:'เกินแผนแล้ว'}
              : ratio > el + .05 ? {c:'warn', t:'ใช้เร็วกว่าแผน'}
              : {c:'ok', t:'อยู่ในแผน'};

  return `
  <div class="grid" style="gap:18px">
    <section class="kpi">
      <div>
        <div class="k"><i style="background:var(--income)"></i>รายรับ${S.range.period==='month'?'เดือนนี้':'ช่วงนี้'}</div>
        <div class="v num" style="color:var(--income)">${baht(income)}</div>
        <div class="sub">${list.filter(t=>t.type==='income').length} รายการ</div>
      </div>
      <div>
        <div class="k"><i style="background:var(--expense)"></i>รายจ่าย${S.range.period==='month'?'เดือนนี้':'ช่วงนี้'}</div>
        <div class="v num" style="color:var(--expense)">${baht(expense)}</div>
        <div class="sub">${list.filter(t=>t.type==='expense').length} รายการ</div>
      </div>
      <div>
        <div class="k"><i style="background:var(--sea)"></i>คงเหลือสุทธิ</div>
        <div class="v num">${baht(income-expense)}</div>
        <div class="sub">${income-expense >= 0 ? 'เก็บได้จริงในช่วงนี้' : 'ใช้เกินที่หามาได้'}</div>
      </div>
      <div>
        <div class="k"><i style="background:var(--warn)"></i>งบเดือนนี้</div>
        <div class="v num">${(ratio*100).toFixed(0)}%</div>
        <div class="sub">${money0(monthSpent)} / ${money0(budget)}</div>
        <div class="meter"><i style="width:${Math.min(100,ratio*100).toFixed(1)}%;background:${ratio>1?'var(--expense)':(ratio>el+.05?'var(--warn)':'var(--sea)')}"></i></div>
      </div>
    </section>

    <div class="grid g-chart">
      <section class="card">
        <div class="card-h"><div><h3>รายจ่ายแยกตามหมวด</h3><p>${rangeLabel(S.range)}</p></div></div>
        <div class="card-b">${donutSvg(entries, expense)}</div>
      </section>

      <div class="grid" style="gap:18px;align-content:start">
        <section class="card">
          <div class="card-h">
            <div><h3>เทียบกับแผนเดือนนี้</h3><p>ผ่านมา ${(el*100).toFixed(0)}% ของเดือน · เหลืออีก ${daysLeft} วัน</p></div>
            <span class="pill ${status.c}" style="margin-left:auto">${status.t}</span>
          </div>
          <div class="card-b" style="padding-top:8px">
            <div style="display:flex;align-items:baseline;gap:8px">
              <span class="num display" style="font-size:28px;font-weight:700">${baht(monthSpent)}</span>
              <span style="color:var(--ink-soft);font-size:13px">จากงบ ${money(budget)}</span>
            </div>
            <div class="bigbar">
              <i style="width:${Math.min(100,ratio*100).toFixed(1)}%;background:${ratio>1?'var(--expense)':(ratio>el+.05?'var(--warn)':'var(--sea)')}"></i>
              <span class="now" style="left:${(el*100).toFixed(1)}%" data-label="ควรใช้ถึงตรงนี้"
                    ${el>.72?'data-align="right"':(el<.18?'data-align="left"':'')}></span>
            </div>
            <p style="margin:0;font-size:13px;color:var(--ink-soft)">
              ${remain >= 0
                ? `เหลืออีก <b class="num" style="color:var(--ink)">${baht(remain)}</b> ใช้ได้วันละ <b class="num" style="color:var(--ink)">${baht(Math.round(remain/daysLeft))}</b> จนสิ้นเดือน`
                : `ใช้เกินแผนไปแล้ว <b class="num" style="color:var(--expense)">${baht(-remain)}</b> — ลองดูหน้า “แผนงบ” ว่าก้อนไหนบานปลาย`}
            </p>
          </div>
        </section>

        <section class="card">
          <div class="card-h"><div><h3>รายจ่ายราย${S.range.period==='year'?'เดือน':'วัน'}</h3>
            <p>${S.range.period==='day'?'ย้อนหลัง 14 วัน':rangeLabel(S.range)} · ชี้ที่แท่งเพื่อดูยอด</p></div></div>
          <div class="card-b">${barsSvg()}</div>
        </section>
      </div>
    </div>

    <section class="kpi" style="grid-template-columns:repeat(3,minmax(0,1fr))">
      <div>
        <div class="k">ค่ากิน${{day:'วันนี้',week:'สัปดาห์นี้',month:'เดือนนี้',year:'ปีนี้'}[S.range.period]}</div>
        <div class="v num" style="font-size:20px">${money0(fs)}</div>
        <div class="sub">งบ ${money0(fb)}</div>
        <div class="meter"><i style="width:${fb?Math.min(100,fs/fb*100).toFixed(1):0}%;background:${fs>fb?'var(--expense)':'var(--warn)'}"></i></div>
      </div>
      <div>
        <div class="k">หนี้คงเหลือ</div>
        <div class="v num" style="font-size:20px">${kbaht(debtLeft)}</div>
        <div class="sub">${DATA.debts.filter(d=>left(d)>0).length} ก้อนที่ยังผ่อนอยู่</div>
      </div>
      <div>
        <div class="k">เก็บได้เดือนนี้</div>
        <div class="v num" style="font-size:20px;color:${savedThisMonth>=0?'var(--income)':'var(--expense)'}">${kbaht(savedThisMonth)}</div>
        <div class="sub">แผนตั้งไว้ ${kbaht(netIncome()-budget)}</div>
      </div>
    </section>

    <section class="card">
      <div class="card-h"><div><h3>รายการล่าสุด</h3><p>10 รายการล่าสุดในช่วงนี้</p></div>
        <button class="btn" data-nav="list" style="margin-left:auto">ดูทั้งหมด</button></div>
      <div class="card-b" style="padding-left:6px;padding-right:6px">
        ${list.length ? tableShell(txRows([...list].sort((a,b)=>b.date.localeCompare(a.date)).slice(0,10), false))
                      : `<div class="empty"><div class="big">🏖️</div>ยังไม่มีรายการในช่วงนี้</div>`}
      </div>
    </section>
  </div>`;
}

/* ---------- 9. หน้า: รายการ ---------- */
function pageList(){
  let list = inWindow();
  if(S.filterType!=='all') list = list.filter(t=>t.type===S.filterType);
  if(S.filterCat)          list = list.filter(t=>t.categoryId===S.filterCat);
  if(S.query){
    const q = S.query;
    list = list.filter(t => (t.note||'').toLowerCase().includes(q) || cat(t.categoryId).n.includes(q));
  }
  const sorted = [...list].sort((a,b)=>
    S.sort==='amount' ? b.amount-a.amount : b.date.localeCompare(a.date));

  const income = sumBy(list,'income'), expense = sumBy(list,'expense');
  const usedCats = [...new Set(inWindow().map(t=>t.categoryId))];

  return `
  <div class="grid" style="gap:18px">
    <section class="kpi" style="grid-template-columns:repeat(3,minmax(0,1fr))">
      <div><div class="k">ที่กรองอยู่</div><div class="v num">${list.length}</div><div class="sub">จาก ${inWindow().length} รายการในช่วงนี้</div></div>
      <div><div class="k"><i style="background:var(--income)"></i>รวมรายรับ</div><div class="v num" style="color:var(--income)">${baht(income)}</div></div>
      <div><div class="k"><i style="background:var(--expense)"></i>รวมรายจ่าย</div><div class="v num" style="color:var(--expense)">${baht(expense)}</div></div>
    </section>

    <section class="card">
      <div class="card-b" style="padding-bottom:12px">
        <div class="filterbar">
          <div class="searchbox">${ICON.search}
            <input class="input" id="q" value="${esc(S.query)}" placeholder="ค้นหาจากโน้ตหรือหมวดหมู่" aria-label="ค้นหารายการ">
          </div>
          <button class="chip" data-ftype="all"     aria-pressed="${S.filterType==='all'}">ทั้งหมด</button>
          <button class="chip" data-ftype="income"  aria-pressed="${S.filterType==='income'}">รายรับ</button>
          <button class="chip" data-ftype="expense" aria-pressed="${S.filterType==='expense'}">รายจ่าย</button>
          <select class="input" id="sortsel" style="width:auto" aria-label="เรียงลำดับ">
            <option value="date"   ${S.sort==='date'?'selected':''}>เรียงตามวันที่</option>
            <option value="amount" ${S.sort==='amount'?'selected':''}>เรียงตามจำนวนเงิน</option>
          </select>
        </div>
        <div class="filterbar" style="margin-top:10px">
          <button class="chip" data-fcat="" aria-pressed="${!S.filterCat}">ทุกหมวด</button>
          ${usedCats.map(c=>`<button class="chip" data-fcat="${c}" aria-pressed="${S.filterCat===c}">${cat(c).i} ${esc(cat(c).n)}</button>`).join('')}
        </div>
      </div>
      <div class="card-b" style="padding-top:0;padding-left:6px;padding-right:6px">
        ${sorted.length ? tableShell(txRows(sorted, S.sort==='date'))
                        : `<div class="empty"><div class="big">🔍</div>ไม่มีรายการที่ตรงกับที่กรองไว้</div>`}
      </div>
    </section>
  </div>`;
}

/* ---------- 10. หน้า: แผนงบ ---------- */
function pagePlan(){
  const s = DATA.settings, mr = thisMonth(), c = dayCount(mr);
  const monthTx = allTx().filter(t=>inRange(mr,t.date));
  const spent = id => monthTx.filter(t=>t.type==='expense' && t.categoryId===id).reduce((a,t)=>a+t.amount,0);
  const fb = foodBudget(mr), dp = debtPlan(), total = linesTotal() + fb + dp;
  const saving = netIncome() - total;
  const allSpent = sumBy(monthTx,'expense');
  const el = elapsed(mr, TODAY), ratio = total ? allSpent/total : 0;

  const row = (label, hint, ic, color, budget, used) => {
    const r = budget ? used/budget : 0, over = used > budget;
    return `<div class="planrow">
      <div class="nm"><span>${ic}</span><span>${esc(label)}${hint?`<small> · ${esc(hint)}</small>`:''}</span></div>
      <div class="fig"><span class="num" style="color:${over?'var(--expense)':'var(--ink)'}">${money0(used)}</span> <span>/ ${money0(budget)}</span></div>
      <div class="bar"><i style="width:${Math.min(100,r*100).toFixed(1)}%;background:${over?'var(--expense)':color}"></i></div>
    </div>`;
  };
  const wf = (k,v,cls,color) => `<div class="wf ${cls||''}"><span class="k">${k}</span>
    <span class="v num" ${color?`style="color:${color}"`:''}>${v<0?'−':''}${money(Math.abs(v))}</span></div>`;

  return `
  <div class="grid g-2" style="align-items:start">
    <div class="grid" style="gap:18px">
      <section class="card">
        <div class="card-h"><div><h3>เงินเดือนไหลไปไหนบ้าง</h3><p>${rangeLabel(mr)}</p></div></div>
        <div class="card-b waterfall">
          ${wf('เงินเดือน', s.salary, 'strong')}
          ${wf('หักประกันสังคม', -s.socialSecurity)}
          ${s.otherDeduction ? wf('ภาษีหัก ณ ที่จ่าย / อื่น ๆ', -s.otherDeduction) : ''}
          ${wf('รายได้สุทธิ', netIncome(), 'strong')}
          <div style="height:8px"></div>
          ${wf('รายจ่ายคงที่', -linesTotal())}
          ${wf('งบค่ากิน', -fb)}
          ${wf('ผ่อน / จ่ายหนี้', -dp)}
          ${wf('เหลือเก็บตามแผน', saving, 'strong total', saving>=0?'var(--income)':'var(--expense)')}
          <p style="margin:10px 0 0;font-size:12.5px;color:var(--ink-soft)">
            ${saving>=0
              ? `คิดเป็น ${(saving/netIncome()*100).toFixed(0)}% ของรายได้สุทธิ — ยังไม่รวมเงินที่ตั้งใจออมไว้ในหมวด “เก็บออม” ด้านล่าง`
              : `แผนจ่ายเกินรายได้อยู่ ${money(-saving)} ต้องลดก้อนใดก้อนหนึ่งลง`}
          </p>
        </div>
      </section>

      <section class="card">
        <div class="card-h"><div><h3>ใช้ไปแล้วเทียบกับแผน</h3><p>เส้นดำคือจุดที่ควรใช้ถึงตามวันที่ผ่านไป</p></div></div>
        <div class="card-b">
          <div style="display:flex;align-items:baseline;gap:8px">
            <span class="num display" style="font-size:30px;font-weight:700">${baht(allSpent)}</span>
            <span style="color:var(--ink-soft);font-size:13px">/ ${money(total)}</span>
          </div>
          <div class="bigbar">
            <i style="width:${Math.min(100,ratio*100).toFixed(1)}%;background:${ratio>1?'var(--expense)':(ratio<=el+.05?'var(--sea)':'var(--warn)')}"></i>
            <span class="now" style="left:${(el*100).toFixed(1)}%" data-label="${(el*100).toFixed(0)}% ของเดือน"
                  ${el>.72?'data-align="right"':(el<.18?'data-align="left"':'')}></span>
          </div>
        </div>
      </section>
    </div>

    <div class="grid" style="gap:18px">
      <section class="card">
        <div class="card-h"><div><h3>รายจ่ายคงที่</h3><p>${s.lines.length} รายการในสูตร</p></div>
          <div class="aside">รวมต่อเดือน<b class="num">${baht(linesTotal())}</b></div></div>
        <div class="card-b" style="padding-top:6px">
          ${s.lines.map(l => row(l.label,
              l.minAmount ? `ปกติ ${money0(l.minAmount)}–${money0(l.maxAmount)}` : '',
              cat(l.categoryId).i, cat(l.categoryId).c, l.amount, spent(l.categoryId))).join('')}
        </div>
      </section>

      <section class="card">
        <div class="card-h"><div><h3>ค่ากิน</h3>
          <p>วันทำงาน ${c.work} วัน × ${money0(s.foodWorkday)} + วันหยุด ${c.holiday} วัน × ${money0(s.foodHoliday)}</p></div>
          <div class="aside">งบเดือนนี้<b class="num">${baht(fb)}</b></div></div>
        <div class="card-b" style="padding-top:6px">
          ${row('ค่ากินทั้งเดือน','','🍜','var(--warn)', fb, spent('food'))}
        </div>
      </section>

      <section class="card">
        <div class="card-h"><div><h3>ผ่อน / จ่ายหนี้</h3><p>เทียบกับที่ตั้งใจจ่ายเดือนนี้</p></div>
          <div class="aside">รวมต่อเดือน<b class="num">${baht(dp)}</b></div></div>
        <div class="card-b" style="padding-top:6px">
          ${DATA.debts.filter(d=>left(d)>0).map(d => row(d.name, `คงเหลือ ${money0(left(d))}`, '🤝', 'var(--c7)',
              d.monthlyPlan || left(d), monthTx.filter(t=>t.debtId===d.id).reduce((a,t)=>a+t.amount,0))).join('')
            || `<div class="empty" style="padding:24px">ไม่มีหนี้ค้างแล้ว 🎉</div>`}
        </div>
      </section>
    </div>
  </div>`;
}

/* ---------- 11. หน้า: หนี้ ---------- */
function pageDebts(){
  const totalPrincipal = DATA.debts.reduce((a,d)=>a+d.principal,0);
  const totalPaid = DATA.debts.reduce((a,d)=>a+d.paid,0);
  const totalLeft = DATA.debts.reduce((a,d)=>a+left(d),0);
  const active = DATA.debts.filter(d=>left(d)>0);
  const done = DATA.debts.filter(d=>left(d)<=0);

  const card = d => {
    const cleared = left(d) <= 0;
    const p = d.principal ? Math.min(1, d.paid/d.principal) : 1;
    const months = d.monthlyPlan > 0 ? Math.ceil(left(d)/d.monthlyPlan) : null;
    return `<section class="card" style="${cleared?'opacity:.7':''}">
      <div class="card-b">
        <div class="debt-head">
          <span class="ic" style="background:${cleared?'var(--income-wash)':'var(--expense-wash)'};color:${cleared?'var(--income)':'var(--expense)'}">${cleared?'✓':'🤝'}</span>
          <div style="min-width:0">
            <div class="nm">${esc(d.name)}</div>
            <div class="no">${esc(d.note || 'ยอดตั้งต้น ' + money0(d.principal))}</div>
          </div>
          <div class="rt"><b class="num" style="color:${cleared?'var(--income)':'var(--expense)'}">${baht(left(d))}</b><small>คงเหลือ</small></div>
        </div>
        <div class="planrow" style="border:0;padding:14px 0 0">
          <div class="bar" style="height:8px"><i style="width:${(p*100).toFixed(1)}%;background:${cleared?'var(--income)':'var(--lagoon)'}"></i></div>
        </div>
        <div style="display:flex;align-items:center;gap:10px;margin-top:10px;flex-wrap:wrap">
          <span style="font-size:12.5px;color:var(--ink-soft)">จ่ายแล้ว <b class="num" style="color:var(--ink)">${money0(d.paid)}</b> / ${money0(d.principal)} (${(p*100).toFixed(0)}%)</span>
          ${months ? `<span class="pill ${months<=3?'ok':'info'}">อีก ${months} งวด</span>` : ''}
          ${cleared ? '' : `<button class="btn btn-primary" data-pay="${d.id}" style="margin-left:auto">บันทึกการจ่าย</button>`}
        </div>
      </div>
    </section>`;
  };

  return `
  <div class="grid" style="gap:18px">
    <section class="kpi" style="grid-template-columns:repeat(3,minmax(0,1fr))">
      <div><div class="k"><i style="background:var(--expense)"></i>ยอดคงเหลือรวม</div>
        <div class="v num" style="color:var(--expense)">${baht(totalLeft)}</div>
        <div class="sub">${active.length} ก้อนที่ยังผ่อนอยู่</div></div>
      <div><div class="k"><i style="background:var(--income)"></i>จ่ายไปแล้ว</div>
        <div class="v num" style="color:var(--income)">${baht(totalPaid)}</div>
        <div class="sub">จากยอดตั้งต้นรวม ${money0(totalPrincipal)}</div>
        <div class="meter"><i style="width:${totalPrincipal?(totalPaid/totalPrincipal*100).toFixed(1):0}%;background:var(--income)"></i></div></div>
      <div><div class="k"><i style="background:var(--sea)"></i>ภาระต่อเดือน</div>
        <div class="v num">${baht(debtPlan())}</div>
        <div class="sub">${(debtPlan()/netIncome()*100).toFixed(0)}% ของรายได้สุทธิ</div></div>
    </section>

    <div class="debtgrid">${active.map(card).join('')}</div>
    ${done.length ? `<h3 style="font-size:14px;color:var(--ink-soft);margin-top:8px">ปิดยอดแล้ว</h3>
      <div class="debtgrid">${done.map(card).join('')}</div>` : ''}
  </div>`;
}

/* ---------- 12. หน้า: ตั้งค่า ---------- */
function pageSettings(){
  const s = DATA.settings, c = dayCount(thisMonth());
  const num = (key,label,hint) => `<div class="field">
    <label for="set_${key}">${label}</label>
    <input class="input num" id="set_${key}" data-set="${key}" inputmode="decimal" value="${s[key]}">
    ${hint?`<span style="font-size:11.5px;color:var(--ink-soft)">${hint}</span>`:''}
  </div>`;

  return `
  <div class="grid g-2" style="align-items:start">
    <section class="card">
      <div class="card-h"><div><h3>รายได้และเงินหัก</h3><p>ใช้คำนวณทุกอย่างในหน้า “แผนงบ”</p></div>
        <div class="aside">รายได้สุทธิ<b class="num">${baht(netIncome())}</b></div></div>
      <div class="card-b">
        <div class="formgrid">
          ${num('salary','เงินเดือน (ก่อนหัก)')}
          ${num('socialSecurity','ประกันสังคม')}
          ${num('otherDeduction','ภาษีหัก ณ ที่จ่าย / อื่น ๆ')}
          ${num('payday','เงินเดือนออกวันที่')}
        </div>
      </div>
    </section>

    <section class="card">
      <div class="card-h"><div><h3>ค่ากินต่อวัน</h3><p>เดือนนี้มีวันทำงาน ${c.work} วัน และวันหยุด ${c.holiday} วัน</p></div>
        <div class="aside">งบเดือนนี้<b class="num">${baht(foodBudget(thisMonth()))}</b></div></div>
      <div class="card-b">
        <div class="formgrid">
          ${num('foodWorkday','วันทำงาน / วัน')}
          ${num('foodHoliday','วันหยุด / วัน')}
        </div>
      </div>
    </section>

    <section class="card span2" style="grid-column:1/-1">
      <div class="card-h"><div><h3>สูตรแบ่งรายจ่ายคงที่</h3><p>แก้ตัวเลขได้ทันที ผลจะไปโผล่ที่หน้าแผนงบ</p></div>
        <div class="aside">รวมต่อเดือน<b class="num">${baht(linesTotal())}</b></div></div>
      <div class="card-b">
        <div class="formgrid" style="grid-template-columns:repeat(auto-fill,minmax(230px,1fr))">
          ${s.lines.map(l=>`<div class="field">
            <label for="ln_${l.id}">${cat(l.categoryId).i} ${esc(l.label)}</label>
            <input class="input num" id="ln_${l.id}" data-line="${l.id}" inputmode="decimal" value="${l.amount}">
          </div>`).join('')}
        </div>
      </div>
    </section>

    <section class="card" style="grid-column:1/-1">
      <div class="card-h"><div><h3>ข้อมูลชุดทดสอบ</h3><p>ทุกอย่างเก็บใน localStorage ของเบราว์เซอร์คุณเท่านั้น ไม่มีเซิร์ฟเวอร์</p></div></div>
      <div class="card-b" style="display:flex;gap:10px;flex-wrap:wrap;align-items:center">
        <button class="btn" id="export">ดาวน์โหลด JSON ปัจจุบัน</button>
        <button class="btn btn-danger" id="reset2">รีเซ็ตกลับเป็นข้อมูลตัวอย่าง</button>
        <span style="font-size:12.5px;color:var(--ink-soft)">
          ${DATA.transactions.length} รายการ · ${DATA.debts.length} ก้อนหนี้ · ชุดข้อมูลตั้งต้นอยู่ที่ <code>data/seed.json</code>
        </span>
      </div>
    </section>
  </div>`;
}

/* ---------- 13. โมดัลเพิ่ม / แก้ไข ---------- */
function openEditor(preset){
  const base = {type:'expense', amount:'', categoryId:'food', date:iso(TODAY), note:'', debtId:'', slip:false, id:null};
  S.editing = Object.assign(base, preset||{});
  renderModal();
}
function openDetail(id){ S.detail = id; renderModal(); }
function closeModal(){ S.editing = null; S.detail = null; renderModal(); }

function modalEditor(){
  const f = S.editing;
  const cats = f.type==='income' ? INCOME_CATS : EXPENSE_CATS;
  return `
  <div class="modal-h">
    <h2>${f.id ? 'แก้ไขรายการ' : 'เพิ่มรายการใหม่'}</h2>
    <button class="btn btn-icon" data-close style="margin-left:auto" aria-label="ปิด">${ICON.x}</button>
  </div>
  <div class="modal-b">
    <div class="typetoggle" style="margin-bottom:18px">
      <button data-t="expense" aria-pressed="${f.type==='expense'}">↗ รายจ่าย</button>
      <button data-t="income"  aria-pressed="${f.type==='income'}">↙ รายรับ</button>
    </div>

    <div class="field">
      <label for="f_amount">จำนวนเงิน (บาท)</label>
      <div class="amountbox"><span>฿</span>
        <input id="f_amount" inputmode="decimal" placeholder="0" value="${esc(f.amount)}" autocomplete="off">
      </div>
      <div class="quick">
        ${[100,300,500,1000,5000].map(v=>`<button data-add="${v}">+${money0(v)}</button>`).join('')}
        <button data-add="clear">ล้าง</button>
      </div>
    </div>

    <div class="field" style="margin-top:18px">
      <label>หมวดหมู่</label>
      <div class="catgrid">
        ${cats.map(c=>`<button data-cat="${c}" aria-pressed="${f.categoryId===c}"
          style="${f.categoryId===c?`background:${cat(c).c}`:''}">${cat(c).i} ${esc(cat(c).n)}</button>`).join('')}
      </div>
    </div>

    <div class="formgrid" style="margin-top:18px">
      <div class="field">
        <label for="f_date">วันที่</label>
        <input class="input" type="date" id="f_date" value="${f.date}">
      </div>
      ${f.categoryId==='debt' ? `
      <div class="field">
        <label for="f_debt">ตัดจากหนี้ก้อนไหน</label>
        <select class="input" id="f_debt">
          <option value="">ไม่ผูกกับก้อนหนี้</option>
          ${DATA.debts.map(d=>`<option value="${d.id}" ${f.debtId===d.id?'selected':''}>${esc(d.name)} · เหลือ ${money0(left(d))}</option>`).join('')}
        </select>
      </div>` : `<div class="field">
        <label for="f_slip">แนบสลิป</label>
        <select class="input" id="f_slip">
          <option value="0" ${!f.slip?'selected':''}>ไม่ได้แนบ</option>
          <option value="1" ${f.slip?'selected':''}>แนบสลิปแล้ว 🧾</option>
        </select>
      </div>`}
      <div class="field span2">
        <label for="f_note">โน้ต</label>
        <input class="input" id="f_note" value="${esc(f.note)}" placeholder="เช่น ข้าวกลางวันออฟฟิศ, เติมน้ำมัน">
      </div>
    </div>
  </div>
  <div class="modal-f">
    <span class="grow"></span>
    <button class="btn" data-close>ยกเลิก</button>
    <button class="btn btn-primary" id="savetx">${f.id ? 'บันทึกการแก้ไข' : 'เพิ่มรายการ'}</button>
  </div>`;
}

function modalDetail(){
  const t = allTx().find(x=>x.id===S.detail);
  if(!t) return '';
  const c = cat(t.categoryId), inc = t.type==='income', d = t.debtId ? debtOf(t.debtId) : null;
  const kv = (k,v)=>`<div style="display:flex;gap:14px;padding:9px 0;border-bottom:1px solid var(--line-soft)">
    <span style="width:110px;flex:none;color:var(--ink-soft);font-size:12.5px">${k}</span>
    <span style="font-weight:600;font-size:13.5px">${v}</span></div>`;
  return `
  <div class="modal-h">
    <h2>รายละเอียดรายการ</h2>
    <button class="btn btn-icon" data-close style="margin-left:auto" aria-label="ปิด">${ICON.x}</button>
  </div>
  <div class="modal-b">
    <div style="display:flex;align-items:center;gap:16px;margin-bottom:18px">
      <span style="width:56px;height:56px;border-radius:18px;display:grid;place-items:center;font-size:24px;background:color-mix(in srgb,${c.c} 16%,transparent)">${c.i}</span>
      <div>
        <div class="num display" style="font-size:30px;font-weight:700;color:${inc?'var(--income)':'var(--expense)'}">${inc?'+':'−'}${baht(t.amount)}</div>
        <div style="color:var(--ink-soft);font-size:13px">${inc?'รายรับ':'รายจ่าย'} · ${esc(c.n)}</div>
      </div>
    </div>
    ${kv('วันที่', dfmt(parse(t.date),{weekday:'long',day:'numeric',month:'long',year:'numeric'}))}
    ${kv('โน้ต', esc(t.note || '—'))}
    ${d ? kv('ตัดจากหนี้', `${esc(d.name)} · เหลือ ${baht(left(d))}`) : ''}
    ${kv('สลิป', t.slip ? 'แนบไว้แล้ว 🧾' : 'ไม่ได้แนบ')}
    ${kv('รหัสรายการ', `<code>${esc(t.id)}</code>`)}
  </div>
  <div class="modal-f">
    <button class="btn btn-danger" data-del="${t.id}">ลบรายการ</button>
    <span class="grow"></span>
    <button class="btn" data-close>ปิด</button>
    <button class="btn btn-primary" data-edit="${t.id}">แก้ไข</button>
  </div>`;
}

/* ---------- 14. เรนเดอร์ ---------- */
const $ = sel => document.querySelector(sel);
const PAGES = {
  home:    {title:'ภาพรวม',   sub:'สรุปรายรับรายจ่ายและสถานะเทียบกับแผน', icon:'home', render:pageHome},
  list:    {title:'รายการ',   sub:'ทุกรายการในช่วงที่เลือก ค้นหาและกรองได้', icon:'list', render:pageList},
  plan:    {title:'แผนงบ',    sub:'สูตรแบ่งรายจ่ายจากเงินเดือน', icon:'plan', render:pagePlan},
  debts:   {title:'หนี้',      sub:'ยอดคงเหลือและความคืบหน้าแต่ละก้อน', icon:'debt', render:pageDebts},
  settings:{title:'ตั้งค่า',   sub:'ปรับตัวเลขแล้วทุกหน้าคำนวณใหม่ทันที', icon:'cog', render:pageSettings},
};

function renderNav(){
  $('#nav').innerHTML = Object.entries(PAGES).map(([k,p])=>{
    const badge = k==='list' ? `<span class="count">${inWindow().length}</span>`
                : k==='debts' ? `<span class="count">${DATA.debts.filter(d=>left(d)>0).length}</span>` : '';
    return `<button data-nav="${k}" ${S.page===k?'aria-current="page"':''}>${ICON[p.icon]}<span>${p.title}</span>${badge}</button>`;
  }).join('');
}

function renderTopbar(){
  const p = PAGES[S.page];
  const showRange = S.page==='home' || S.page==='list';
  $('#topbar').innerHTML = `
    <button class="btn btn-icon menu-btn" id="menu" aria-label="เปิดเมนู">${ICON.menu}</button>
    <div class="ttl"><h1>${p.title}</h1><p>${p.sub}</p></div>
    <div class="tools">
      ${showRange ? `
        <div class="seg" role="group" aria-label="ช่วงเวลา">
          ${[['day','วัน'],['week','สัปดาห์'],['month','เดือน'],['year','ปี']].map(([k,l])=>
            `<button data-period="${k}" aria-pressed="${S.range.period===k}">${l}</button>`).join('')}
        </div>
        <div class="stepper">
          <button data-shift="-1" aria-label="ช่วงก่อนหน้า">‹</button>
          <span class="lab">${rangeLabel(S.range)}</span>
          <button data-shift="1" aria-label="ช่วงถัดไป">›</button>
        </div>` : ''}
      <button class="btn btn-icon" id="theme" aria-label="สลับโหมดสว่าง/มืด"></button>
      <button class="btn btn-icon" id="reset" aria-label="รีเซ็ตข้อมูลตัวอย่าง" title="รีเซ็ตข้อมูลตัวอย่าง">${ICON.reset}</button>
      <button class="btn btn-primary" id="add">${ICON.plus}<span>เพิ่มรายการ</span></button>
    </div>`;
  syncThemeIcon();
}

function renderModal(){
  const bg = $('#modal-bg'), box = $('#modal');
  if(S.editing)      box.innerHTML = modalEditor();
  else if(S.detail)  box.innerHTML = modalDetail();
  else { bg.classList.remove('on'); document.body.style.overflow=''; return; }
  bg.classList.add('on');
  document.body.style.overflow='hidden';
  const amt = $('#f_amount'); if(amt && !amt.value) amt.focus();
}

function render(){
  renderNav();
  renderTopbar();
  $('#page').innerHTML = PAGES[S.page].render();
  renderModal();
}

function toast(msg){
  const el = $('#toast');
  el.textContent = msg; el.classList.add('on');
  clearTimeout(el._t); el._t = setTimeout(()=>el.classList.remove('on'), 2200);
}

/* ---------- 15. ธีม ---------- */
function currentTheme(){
  const stored = localStorage.getItem('beachbudget.theme');
  if(stored) return stored;
  return matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}
function syncThemeIcon(){
  const b = $('#theme'); if(!b) return;
  b.innerHTML = currentTheme()==='dark' ? ICON.sun : ICON.moon;
}
function toggleTheme(){
  const next = currentTheme()==='dark' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-theme', next);
  localStorage.setItem('beachbudget.theme', next);
  syncThemeIcon();
}

/* ---------- 16. เหตุการณ์ ---------- */
document.addEventListener('click', e => {
  const el = e.target.closest('[data-nav],[data-period],[data-shift],[data-ftype],[data-fcat],[data-tx],[data-pay],[data-add],[data-cat],[data-t],[data-close],[data-del],[data-edit],#add,#theme,#reset,#reset2,#savetx,#menu,#export,.scrim');
  if(!el) return;

  if(el.id==='menu'){ $('#sidebar').classList.toggle('open'); $('#scrim').classList.toggle('on'); return; }
  if(el.classList.contains('scrim')){ $('#sidebar').classList.remove('open'); el.classList.remove('on'); return; }
  if(el.id==='theme'){ toggleTheme(); return; }
  if(el.id==='add'){ openEditor(); return; }
  if(el.id==='reset' || el.id==='reset2'){
    if(confirm('ล้างข้อมูลที่แก้ไว้ แล้วกลับไปใช้ชุดตัวอย่างตั้งต้น?')){
      wipe(); DATA = structuredClone(SEED); S.range = makeRange(S.range.period, TODAY);
      closeModal(); render(); toast('กลับไปเป็นข้อมูลตัวอย่างแล้ว');
    }
    return;
  }
  if(el.id==='export'){ downloadJson(); return; }

  if(el.dataset.nav){
    S.page = el.dataset.nav; window.scrollTo({top:0});
    $('#sidebar').classList.remove('open'); $('#scrim').classList.remove('on');
    render(); return;
  }
  if(el.dataset.period){ S.range = makeRange(el.dataset.period, TODAY); render(); return; }
  if(el.dataset.shift){ S.range = shiftRange(S.range, Number(el.dataset.shift)); render(); return; }
  if(el.dataset.ftype){ S.filterType = el.dataset.ftype; render(); return; }
  if('fcat' in el.dataset){ S.filterCat = el.dataset.fcat || null; render(); return; }
  if(el.dataset.tx){ openDetail(el.dataset.tx); return; }

  if(el.dataset.pay){
    const d = debtOf(el.dataset.pay);
    openEditor({categoryId:'debt', debtId:d.id, note:`ผ่อน${d.name}`,
      amount:String(Math.min(d.monthlyPlan || left(d), left(d)))});
    return;
  }
  if(el.dataset.edit){
    const t = allTx().find(x=>x.id===el.dataset.edit);
    S.detail = null;
    openEditor({...t, amount:String(t.amount), debtId:t.debtId||''});
    return;
  }
  if(el.dataset.del){
    const i = allTx().findIndex(x=>x.id===el.dataset.del);
    const t = allTx()[i];
    if(t.debtId){ const d = debtOf(t.debtId); if(d) d.paid = Math.max(0, d.paid - t.amount); }
    allTx().splice(i,1); save(); closeModal(); render();
    toast(t.debtId ? 'ลบรายการแล้ว — คืนยอดหนี้ให้เรียบร้อย' : 'ลบรายการแล้ว');
    return;
  }
  if(el.hasAttribute('data-close')){ closeModal(); return; }

  /* ในโมดัล */
  if(el.dataset.add){
    readEditor();
    const box = $('#f_amount');
    box.value = el.dataset.add==='clear' ? '' : String((parseFloat(box.value)||0) + Number(el.dataset.add));
    S.editing.amount = box.value; box.focus(); return;
  }
  if(el.dataset.t){ readEditor(); S.editing.type = el.dataset.t;
    S.editing.categoryId = el.dataset.t==='income' ? 'salary' : 'food'; renderModal(); return; }
  if(el.dataset.cat){ readEditor(); S.editing.categoryId = el.dataset.cat; renderModal(); return; }

  if(el.id==='savetx'){
    readEditor();
    const f = S.editing, amount = parseFloat(f.amount) || 0;
    if(amount <= 0){ toast('ใส่จำนวนเงินก่อนนะ'); $('#f_amount')?.focus(); return; }

    if(f.id){
      const old = allTx().find(x=>x.id===f.id);
      if(old.debtId){ const d = debtOf(old.debtId); if(d) d.paid = Math.max(0, d.paid - old.amount); }
      Object.assign(old, {type:f.type, amount, categoryId:f.categoryId, date:f.date,
        note:f.note, slip:!!f.slip, debtId: f.categoryId==='debt' ? (f.debtId||null) : null});
      if(old.debtId){ const d = debtOf(old.debtId); if(d) d.paid = Math.min(d.principal, d.paid + amount); }
      toast('แก้ไขรายการแล้ว');
    }else{
      const tx = {id:'t'+Date.now().toString(36), type:f.type, amount, categoryId:f.categoryId,
        date:f.date, note:f.note, slip:!!f.slip, debtId: f.categoryId==='debt' ? (f.debtId||null) : null};
      allTx().push(tx);
      if(tx.debtId){ const d = debtOf(tx.debtId); if(d) d.paid = Math.min(d.principal, d.paid + amount); }
      S.range = makeRange(S.range.period, parse(tx.date));
      toast('เพิ่มรายการแล้ว 🌊');
    }
    save(); closeModal(); render();
  }
});

/** อ่านค่าที่พิมพ์ค้างไว้ก่อนวาดโมดัลใหม่ */
function readEditor(){
  if(!S.editing) return;
  const g = id => document.getElementById(id);
  if(g('f_amount')) S.editing.amount = g('f_amount').value.trim();
  if(g('f_date'))   S.editing.date   = g('f_date').value || S.editing.date;
  if(g('f_note'))   S.editing.note   = g('f_note').value;
  if(g('f_debt'))   S.editing.debtId = g('f_debt').value;
  if(g('f_slip'))   S.editing.slip   = g('f_slip').value === '1';
}

document.addEventListener('input', e => {
  const el = e.target;
  if(el.id === 'q'){
    S.query = el.value.trim().toLowerCase();
    const pos = el.selectionStart;
    render();
    const again = $('#q'); if(again){ again.focus(); again.setSelectionRange(pos,pos); }
    return;
  }
  if(el.dataset.set){
    DATA.settings[el.dataset.set] = parseFloat(el.value) || 0;
    save();
    // อัปเดตเฉพาะตัวเลขสรุปหัวการ์ด ไม่วาดใหม่ทั้งหน้า จะได้ไม่หลุดโฟกัส
    refreshSettingsTotals();
    return;
  }
  if(el.dataset.line){
    const line = DATA.settings.lines.find(l=>l.id===el.dataset.line);
    if(line){ line.amount = parseFloat(el.value) || 0; save(); refreshSettingsTotals(); }
    return;
  }
  if(S.editing){
    if(el.id==='f_amount') S.editing.amount = el.value;
    if(el.id==='f_note')   S.editing.note   = el.value;
    if(el.id==='f_date')   S.editing.date   = el.value;
  }
});
document.addEventListener('change', e => {
  if(e.target.id === 'sortsel'){ S.sort = e.target.value; render(); }
  if(S.editing && e.target.id === 'f_debt') S.editing.debtId = e.target.value;
  if(S.editing && e.target.id === 'f_slip') S.editing.slip = e.target.value === '1';
});
document.addEventListener('keydown', e => {
  if(e.key === 'Escape' && (S.editing || S.detail)) closeModal();
  if(e.key === 'Enter'  && e.target.closest('tr[data-tx]')) openDetail(e.target.closest('tr[data-tx]').dataset.tx);
});
$('#modal-bg')?.addEventListener('click', e => { if(e.target.id === 'modal-bg') closeModal(); });

/** อัปเดตยอดรวมในหน้าตั้งค่าโดยไม่วาดใหม่ทั้งหน้า */
function refreshSettingsTotals(){
  if(S.page !== 'settings') return;
  const asides = document.querySelectorAll('#page .card-h .aside b');
  const vals = [baht(netIncome()), baht(foodBudget(thisMonth())), baht(linesTotal())];
  asides.forEach((el,i)=>{ if(vals[i]) el.textContent = vals[i]; });
}

/** ดาวน์โหลด JSON ปัจจุบัน */
function downloadJson(){
  const blob = new Blob([JSON.stringify(DATA,null,2)],{type:'application/json'});
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = 'beach-budget-data.json';
  document.body.appendChild(a); a.click(); a.remove();
  setTimeout(()=>URL.revokeObjectURL(a.href), 1000);
  toast('ดาวน์โหลดไฟล์ JSON แล้ว');
}

/* ---------- 17. เริ่มทำงาน ---------- */
async function boot(){
  // ธีมที่เคยเลือกไว้
  const stored = localStorage.getItem('beachbudget.theme');
  if(stored) document.documentElement.setAttribute('data-theme', stored);

  try{
    const res = await fetch('./data/seed.json', {cache:'no-store'});
    if(!res.ok) throw new Error('HTTP ' + res.status);
    SEED = await res.json();
  }catch(err){
    $('#page').innerHTML = `
      <div class="card" style="max-width:600px;margin:40px auto">
        <div class="card-b">
          <h3 style="margin-bottom:10px">โหลด <code>data/seed.json</code> ไม่ได้</h3>
          <p style="color:var(--ink-soft)">เบราว์เซอร์บล็อกการอ่านไฟล์เมื่อเปิดด้วย <code>file://</code>
          ให้เปิดผ่านเซิร์ฟเวอร์เล็ก ๆ แทน แล้วเข้า <code>http://localhost:8000</code></p>
          <pre style="background:var(--surface-2);border:1px solid var(--line);border-radius:12px;padding:14px;overflow-x:auto"><code>cd beach-budget-web
python3 -m http.server 8000</code></pre>
          <p style="color:var(--ink-soft);font-size:12.5px;margin-bottom:0">บน GitHub Pages ใช้งานได้ตามปกติ ไม่ต้องทำอะไรเพิ่ม</p>
        </div>
      </div>`;
    $('#topbar').innerHTML = '<div class="ttl"><h1>Beach Budget</h1><p>โหลดข้อมูลไม่สำเร็จ</p></div>';
    return;
  }

  let saved = null;
  try{ saved = JSON.parse(localStorage.getItem(STORE_KEY) || 'null'); }catch(e){}
  DATA = saved && saved.transactions ? saved : structuredClone(SEED);

  TODAY = SEED.meta?.demoToday ? new Date(SEED.meta.demoToday + 'T09:00:00') : new Date();
  S.range = makeRange('month', TODAY);

  const o = SEED.meta?.owner || {};
  $('#who').innerHTML = `<span class="av">${(o.name||'ผ')[0]}</span>
    <div><div class="nm">${esc(o.name||'ผู้ใช้ทดสอบ')}</div><div class="em">${esc(o.email||'')}</div></div>`;

  render();
}
boot();
