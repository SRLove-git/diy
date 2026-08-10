#!/usr/bin/env python3
"""Build the full mobile-app design board HTML (all screens in one grid)."""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))

CSS = r"""
* { margin:0; padding:0; box-sizing:border-box; -webkit-font-smoothing:antialiased; }
:root{
  --bg:#FFFFFF; --surface:#F7F7F8; --ink:#141414; --sec:#8E8E93; --ter:#C7C7CC; --line:#EFEFEF;
  --grad:linear-gradient(135deg,#333333 0%,#141414 100%);
  --gradsoft:linear-gradient(135deg,#F4F4F6 0%,#ECECEF 100%);
  --ok:#34C759; --warn:#FF9500; --danger:#FF3B30;
  --font:-apple-system,"PingFang SC","Noto Sans SC","Helvetica Neue",sans-serif;
}
html,body{width:0;height:0;background:#FFFFFF;font-family:var(--font);color:var(--ink);font-size:15px;line-height:1.4;}
.screen{position:absolute;width:390px;height:844px;background:#FFFFFF;overflow:hidden;color:var(--ink);}

/* ---------- status bar ---------- */
.status{height:62px;display:flex;align-items:center;justify-content:space-between;padding:0 28px 0 32px;}
.status .time{font-size:16px;font-weight:600;letter-spacing:-0.2px;}
.sicons{display:flex;align-items:center;gap:7px;}
.sig{width:18px;height:11px;display:flex;gap:2px;align-items:flex-end;}
.sig i{display:block;width:3px;background:var(--ink);border-radius:1px;}
.sig i:nth-child(1){height:4px}.sig i:nth-child(2){height:6px}.sig i:nth-child(3){height:8px}.sig i:nth-child(4){height:11px}
.sig.w i{background:#fff;}
.wifi{width:16px;height:11px;border:1.6px solid var(--ink);border-bottom:none;border-radius:8px 8px 0 0;position:relative;}
.wifi:after{content:"";position:absolute;left:6px;bottom:-2px;width:2px;height:3px;background:var(--ink);border-radius:1px;}
.batt{width:24px;height:12px;border:1.5px solid var(--ink);border-radius:4px;padding:2px;position:relative;}
.batt:after{content:"";display:block;width:11px;height:6px;background:var(--ink);border-radius:1.5px;}
.batt:before{content:"";position:absolute;right:-3px;top:3px;width:2px;height:4px;background:var(--ink);border-radius:0 1px 1px 0;}

/* ---------- nav header ---------- */
.nav{position:relative;height:44px;display:flex;align-items:center;padding:0 8px;}
.nav .back{width:40px;height:40px;display:flex;align-items:center;justify-content:center;}
.nav .title{position:absolute;left:0;right:0;text-align:center;font-size:17px;font-weight:600;}
.nav .right{position:absolute;right:12px;display:flex;align-items:center;gap:16px;font-size:14px;font-weight:600;}
.nav .rightact{position:absolute;right:16px;font-size:14px;font-weight:600;color:var(--ink);}

/* ---------- icons (pure CSS) ---------- */
.ic{display:inline-block;position:relative;width:22px;height:22px;color:var(--ink);flex:none;}
.ic.ic-lg{width:26px;height:26px;}
.ic.ic-sm{width:18px;height:18px;}
.ic .bd{position:absolute;background:currentColor;}
.ic .ln{position:absolute;border:1.8px solid currentColor;}
.home .roof{position:absolute;top:3px;left:2px;width:0;height:0;border-left:9px solid transparent;border-right:9px solid transparent;border-bottom:8px solid currentColor;}
.home .base{position:absolute;top:9px;left:4px;width:14px;height:10px;background:currentColor;border-radius:2px;}
.srch .c{position:absolute;top:2px;left:2px;width:12px;height:12px;border:2px solid currentColor;border-radius:50%;}
.srch .h{position:absolute;top:15px;left:13px;width:8px;height:2px;background:currentColor;border-radius:1px;transform:rotate(45deg);}
.hrt .l{position:absolute;top:3px;left:2px;width:9px;height:9px;background:currentColor;border-radius:50%;}
.hrt .r{position:absolute;top:3px;left:11px;width:9px;height:9px;background:currentColor;border-radius:50%;}
.hrt .b{position:absolute;top:8px;left:6.5px;width:9px;height:9px;background:currentColor;border-radius:2px;transform:rotate(45deg);}
.cmt .c{position:absolute;top:3px;left:3px;width:16px;height:13px;border:2px solid currentColor;border-radius:7px;}
.cmt .t{position:absolute;top:13px;left:7px;width:6px;height:6px;background:currentColor;transform:rotate(45deg);}
.bmk .b{position:absolute;top:2px;left:4px;width:13px;height:15px;border:2px solid currentColor;border-radius:3px;}
.bmk .v{position:absolute;top:13px;left:7px;width:0;height:0;border-left:4.5px solid transparent;border-right:4.5px solid transparent;border-top:5px solid currentColor;}
.shr .p{position:absolute;top:8px;left:2px;width:0;height:0;border-top:5px solid transparent;border-bottom:5px solid transparent;border-right:11px solid currentColor;}
.shr .l{position:absolute;top:16px;left:2px;width:14px;height:2px;background:currentColor;transform:rotate(-45deg);transform-origin:left top;}
.usr .h{position:absolute;top:1px;left:6px;width:10px;height:10px;background:currentColor;border-radius:50%;}
.usr .b{position:absolute;top:12px;left:2px;width:18px;height:10px;background:currentColor;border-radius:9px 9px 0 0;}
.bl .b{position:absolute;top:2px;left:3px;width:15px;height:15px;border:2px solid currentColor;border-radius:8px 8px 4px 4px;}
.bl .t{position:absolute;top:0;left:6px;width:10px;height:2px;background:currentColor;border-radius:1px;}
.bl .s{position:absolute;top:17px;left:9px;width:4px;height:2px;background:currentColor;}
.pl .v{position:absolute;top:3px;left:10px;width:2px;height:16px;background:currentColor;border-radius:1px;}
.pl .h{position:absolute;top:10px;left:3px;width:16px;height:2px;background:currentColor;border-radius:1px;}
.bk .c{position:absolute;top:5px;left:8px;width:9px;height:9px;border-left:2px solid currentColor;border-bottom:2px solid currentColor;transform:rotate(45deg);}
.cr .c{position:absolute;top:5px;left:6px;width:9px;height:9px;border-top:2px solid currentColor;border-right:2px solid currentColor;transform:rotate(45deg);}
.py{border-top:7px solid transparent;border-bottom:7px solid transparent;border-left:11px solid currentColor;position:absolute;top:4px;left:7px;}
.pa .l{position:absolute;top:4px;left:6px;width:3px;height:14px;background:currentColor;border-radius:1.5px;}
.pa .r{position:absolute;top:4px;left:13px;width:3px;height:14px;background:currentColor;border-radius:1.5px;}
.cam .b{position:absolute;top:4px;left:2px;width:18px;height:14px;border:2px solid currentColor;border-radius:5px;}
.cam .l{position:absolute;top:8px;left:8px;width:6px;height:6px;border:2px solid currentColor;border-radius:50%;}
.mc .b{position:absolute;top:1px;left:6px;width:10px;height:14px;border:2px solid currentColor;border-radius:6px;}
.mc .s{position:absolute;top:16px;left:10px;width:2px;height:5px;background:currentColor;}
.mc .f{position:absolute;top:15px;left:4px;width:14px;height:2px;background:currentColor;border-radius:1px;}
.pin{position:absolute;top:4px;left:4px;width:14px;height:14px;background:currentColor;border-radius:50% 50% 50% 0;transform:rotate(-45deg);}
.pin:after{content:"";position:absolute;top:4px;left:4px;width:4px;height:4px;background:#fff;border-radius:50%;}
.clk .c{position:absolute;top:3px;left:3px;width:16px;height:16px;border:2px solid currentColor;border-radius:50%;}
.clk .h{position:absolute;top:5px;left:10px;width:2px;height:5px;background:currentColor;border-radius:1px;}
.clk .m{position:absolute;top:8px;left:10px;width:2px;height:4px;background:currentColor;border-radius:1px;transform:rotate(90deg);transform-origin:1px 1px;}
.cal .b{position:absolute;top:4px;left:3px;width:16px;height:14px;border:2px solid currentColor;border-radius:4px;}
.cal .l{position:absolute;top:1px;left:6px;width:2px;height:4px;background:currentColor;border-radius:1px;}
.cal .r{position:absolute;top:1px;left:13px;width:2px;height:4px;background:currentColor;border-radius:1px;}
.wal .b{position:absolute;top:4px;left:2px;width:18px;height:14px;border:2px solid currentColor;border-radius:5px;}
.wal .s{position:absolute;top:8px;left:10px;width:8px;height:5px;background:currentColor;border-radius:2px;}
.eye{position:absolute;top:6px;left:2px;width:18px;height:11px;border:2px solid currentColor;border-radius:9px;}
.eye:after{content:"";position:absolute;top:2.5px;left:5.5px;width:5px;height:5px;background:currentColor;border-radius:50%;}
.dots i{position:absolute;top:9px;width:4px;height:4px;background:currentColor;border-radius:50%;}
.dots i:nth-child(1){left:4px}.dots i:nth-child(2){left:9px}.dots i:nth-child(3){left:14px}
.pen{position:absolute;top:11px;left:3px;width:13px;height:4px;background:currentColor;border-radius:1.5px;transform:rotate(-45deg);}
.pen:after{content:"";position:absolute;top:-4px;right:-1px;width:0;height:0;border-left:3px solid transparent;border-right:3px solid transparent;border-bottom:5px solid currentColor;}
.mus .n{position:absolute;top:10px;left:2px;width:8px;height:8px;background:currentColor;border-radius:50%;}
.mus .s{position:absolute;top:2px;left:7px;width:2px;height:11px;background:currentColor;border-radius:1px;}
.mus .f{position:absolute;top:2px;left:9px;width:8px;height:2px;background:currentColor;border-radius:1px;}
.flt .f{position:absolute;top:2px;left:2px;width:18px;height:14px;border:2px solid currentColor;border-radius:4px;}
.flt .s{position:absolute;top:14px;left:9px;width:0;height:0;border-left:4px solid transparent;border-right:4px solid transparent;border-top:5px solid currentColor;}
.grd i{position:absolute;width:9px;height:9px;background:currentColor;border-radius:2px;}
.grd i:nth-child(1){top:2px;left:2px}.grd i:nth-child(2){top:2px;left:13px}.grd i:nth-child(3){top:13px;left:2px}.grd i:nth-child(4){top:13px;left:13px}
.lst i{position:absolute;left:4px;width:14px;height:2px;background:currentColor;border-radius:1px;}
.lst i:nth-child(1){top:5px}.lst i:nth-child(2){top:10px}.lst i:nth-child(3){top:15px}
.menu i{position:absolute;left:3px;width:16px;height:2px;background:currentColor;border-radius:1px;}
.menu i:nth-child(1){top:6px}.menu i:nth-child(2){top:10px}.menu i:nth-child(3){top:14px}
.gear .c{position:absolute;top:6px;left:6px;width:10px;height:10px;border:2px solid currentColor;border-radius:50%;}
.gear .t{position:absolute;top:2px;left:9.5px;width:3px;height:7px;background:currentColor;border-radius:1.5px;transform-origin:1.5px 9px;}
.gear .t1{transform:rotate(0deg);}
.gear .t2{transform:rotate(45deg);}
.gear .t3{transform:rotate(90deg);}
.gear .t4{transform:rotate(135deg);}
.gear .t5{transform:rotate(180deg);}
.gear .t6{transform:rotate(225deg);}
.gear .t7{transform:rotate(270deg);}
.gear .t8{transform:rotate(315deg);}
.flm{position:absolute;top:3px;left:6px;width:10px;height:14px;background:currentColor;border-radius:6px 6px 4px 4px;}
.dmd{position:absolute;top:6px;left:6px;width:10px;height:10px;background:currentColor;border-radius:2px;transform:rotate(45deg);}
.gft .b{position:absolute;top:10px;left:3px;width:16px;height:9px;background:currentColor;border-radius:2px;}
.gft .t{position:absolute;top:5px;left:5px;width:12px;height:4px;background:currentColor;border-radius:1px;}
.gft .r{position:absolute;top:5px;left:11px;width:2px;height:14px;background:currentColor;border-radius:1px;}
.lock .b{position:absolute;top:9px;left:4px;width:14px;height:12px;border:2px solid currentColor;border-radius:4px;}
.lock .h{position:absolute;top:2px;left:7px;width:8px;height:7px;border:2px solid currentColor;border-bottom:none;border-radius:4px 4px 0 0;}
.cmp .c{position:absolute;top:2px;left:2px;width:18px;height:18px;border:2px solid currentColor;border-radius:50%;}
.cmp .n{position:absolute;top:5px;left:10px;width:0;height:0;border-left:3px solid transparent;border-right:3px solid transparent;border-bottom:6px solid currentColor;}
.cmp .s{position:absolute;top:12px;left:10px;width:0;height:0;border-left:3px solid transparent;border-right:3px solid transparent;border-top:6px solid currentColor;}
.reel .b{position:absolute;top:3px;left:2px;width:18px;height:15px;border:2px solid currentColor;border-radius:4px;}
.reel .s{position:absolute;top:8.5px;left:8px;width:0;height:0;border-top:4px solid transparent;border-bottom:4px solid transparent;border-left:7px solid currentColor;}
.msg .b{position:absolute;top:3px;left:3px;width:16px;height:13px;border:2px solid currentColor;border-radius:7px;}
.msg .d{position:absolute;width:2px;height:2px;background:currentColor;border-radius:50%;top:9.5px;}
.msg .d:nth-child(2){left:8px}.msg .d:nth-child(3){left:12px}.msg .d:nth-child(4){left:16px}
.out{position:absolute;top:2px;left:2px;width:15px;height:15px;border:2px solid currentColor;border-radius:50%;}
.out .a{position:absolute;top:9px;left:9px;width:8px;height:2px;background:currentColor;border-radius:1px;}
.out .t{position:absolute;top:8px;left:15px;width:0;height:0;border-top:3px solid transparent;border-bottom:3px solid transparent;border-left:5px solid currentColor;}
.phn .b{position:absolute;top:3px;left:5px;width:12px;height:17px;border:2px solid currentColor;border-radius:4px;}
.phn .s{position:absolute;top:16px;left:9px;width:3px;height:2px;background:currentColor;border-radius:1px;}
.playc{position:absolute;top:8px;left:10px;width:0;height:0;border-top:4px solid transparent;border-bottom:4px solid transparent;border-left:7px solid currentColor;}
.fire{position:absolute;top:2px;left:5px;width:12px;height:16px;background:currentColor;border-radius:7px 7px 4px 4px;}
.fire:after{content:"";position:absolute;top:5px;left:3px;width:6px;height:7px;background:#fff;border-radius:3px 3px 2px 2px;opacity:.85;}
.qrc .q{position:absolute;width:9px;height:9px;border:2px solid currentColor;}
.qrc .q:nth-child(1){top:2px;left:2px}.qrc .q:nth-child(2){top:2px;right:2px}
.qrc .q:nth-child(3){bottom:2px;left:2px}.qrc .q:nth-child(4){bottom:2px;right:2px}
.qrc .d{position:absolute;width:6px;height:6px;background:currentColor;top:8px;left:8px;}
.tkt .b{position:absolute;top:4px;left:2px;width:18px;height:14px;border:2px solid currentColor;border-radius:5px;}
.tkt .d{position:absolute;top:8px;left:10px;width:2px;height:7px;background:currentColor;border-radius:1px;}
.x .a{position:absolute;top:10px;left:3px;width:16px;height:2px;background:currentColor;border-radius:1px;transform:rotate(45deg);}
.x .b{position:absolute;top:10px;left:3px;width:16px;height:2px;background:currentColor;border-radius:1px;transform:rotate(-45deg);}
.hash .v1{position:absolute;top:3px;left:6px;width:2px;height:16px;background:currentColor;border-radius:1px;}
.hash .v2{position:absolute;top:3px;left:13px;width:2px;height:16px;background:currentColor;border-radius:1px;}
.hash .h1{position:absolute;top:7px;left:2px;width:18px;height:2px;background:currentColor;border-radius:1px;transform:rotate(-12deg);}
.hash .h2{position:absolute;top:13px;left:2px;width:18px;height:2px;background:currentColor;border-radius:1px;transform:rotate(-12deg);}
.flash .t{position:absolute;top:3px;left:8px;width:0;height:0;border-left:4px solid transparent;border-right:4px solid transparent;border-bottom:8px solid currentColor;}
.flash .b{position:absolute;top:9px;left:8px;width:0;height:0;border-left:4px solid transparent;border-right:4px solid transparent;border-top:8px solid currentColor;}
.magic .d1{position:absolute;top:3px;left:8px;width:8px;height:8px;background:currentColor;border-radius:1px;transform:rotate(45deg);}
.magic .d2{position:absolute;top:12px;left:3px;width:4px;height:4px;background:currentColor;transform:rotate(45deg);}
.magic .d3{position:absolute;top:15px;left:13px;width:4px;height:4px;background:currentColor;transform:rotate(45deg);}
.adj .l{position:absolute;top:8px;left:2px;width:18px;height:2px;background:currentColor;border-radius:1px;}
.adj .k{position:absolute;top:5px;left:5px;width:8px;height:8px;border-radius:50%;background:#fff;border:2px solid currentColor;}
.crop .c1{position:absolute;top:3px;left:3px;width:12px;height:12px;border:2px solid currentColor;border-radius:2px;}
.crop .c2{position:absolute;top:7px;left:7px;width:12px;height:12px;border:2px solid currentColor;border-radius:2px;}
.stk .b{position:absolute;top:3px;left:3px;width:16px;height:16px;background:currentColor;border-radius:3px;}
.stk .f{position:absolute;top:3px;left:11px;width:0;height:0;border-top:8px solid #fff;border-left:8px solid transparent;}
.txt .t{position:absolute;top:4px;left:9px;width:4px;height:13px;background:currentColor;}
.txt .b{position:absolute;top:4px;left:5px;width:12px;height:4px;background:currentColor;}
.disc{position:absolute;top:1px;left:1px;width:20px;height:20px;border-radius:50%;background:radial-gradient(circle,#fff 0 2px,#141414 2.5px 5px,#fff 5.5px 6px,#141414 6.5px 20px);}
.disc .r{position:absolute;top:6px;left:6px;width:8px;height:8px;border-radius:50%;background:var(--ink);}
.disc .r:after{content:"";position:absolute;top:2px;left:2px;width:4px;height:4px;border-radius:50%;background:#fff;}
.shutter{width:74px;height:74px;border-radius:50%;border:4px solid rgba(255,255,255,.92);position:relative;}
.shutter:after{content:"";position:absolute;inset:7px;border-radius:50%;background:#fff;}
.shutter.press:after{background:#141414;}
.shutter.sm{width:58px;height:58px;}
.camtool{width:44px;height:44px;border-radius:50%;background:rgba(255,255,255,.14);border:1px solid rgba(255,255,255,.28);display:flex;align-items:center;justify-content:center;color:#fff;}
.editool{width:44px;height:44px;border-radius:14px;background:var(--surface);display:flex;align-items:center;justify-content:center;color:var(--ink);}
.editool .lab{position:absolute;bottom:-18px;left:0;right:0;text-align:center;font-size:10px;color:var(--sec);}
.trash .b{position:absolute;top:9px;left:5px;width:12px;height:11px;border:2px solid currentColor;border-radius:2px;}
.trash .l{position:absolute;top:4px;left:7px;width:8px;height:3px;border:1.6px solid currentColor;border-radius:1px;}
.trash .h{position:absolute;top:12px;left:8px;width:6px;height:1.6px;background:currentColor;}
.link .c1{position:absolute;top:6px;left:3px;width:11px;height:11px;border:2px solid currentColor;border-radius:4px;}
.link .c2{position:absolute;top:6px;left:8px;width:11px;height:11px;border:2px solid currentColor;border-radius:4px;}
.dl .a{position:absolute;top:3px;left:10px;width:2px;height:11px;background:currentColor;border-radius:1px;}
.dl .t{position:absolute;top:10px;left:6px;width:0;height:0;border-left:5px solid transparent;border-right:5px solid transparent;border-top:6px solid currentColor;}
.dl .l{position:absolute;top:16px;left:4px;width:14px;height:2px;background:currentColor;border-radius:1px;}
.tick .l{position:absolute;top:9px;left:3px;width:8px;height:2px;background:currentColor;border-radius:1px;transform:rotate(45deg);}
.tick .r{position:absolute;top:9px;left:8px;width:2px;height:2px;background:currentColor;border-radius:1px;}
.udot{width:18px;height:18px;border-radius:50%;background:var(--surface);position:absolute;top:2px;left:2px;}
.udot:after{content:"";position:absolute;top:4px;left:4px;width:10px;height:10px;border-radius:50%;background:var(--danger);}

/* ---------- overlays: dialog / sheet / chat menu / motion ---------- */
.mask{position:absolute;inset:0;background:rgba(20,20,20,.42);z-index:10;}
.dialog{position:absolute;left:50%;top:44%;transform:translate(-50%,-50%);width:312px;background:#fff;border-radius:22px;z-index:11;padding:26px 22px 0;box-shadow:0 24px 64px rgba(0,0,0,.22);}
.dialog .title{font-size:17px;font-weight:700;text-align:center;letter-spacing:-0.2px;}
.dialog .msg{font-size:13px;color:var(--sec);text-align:center;line-height:1.6;margin-top:10px;}
.dialog .btns{display:flex;gap:10px;margin:22px -22px 0;padding:0 22px 22px;}
.dialog .btns .btn{flex:1;height:46px;border-radius:15px;font-size:15px;}
.sheet{position:absolute;left:0;right:0;bottom:0;background:#fff;border-radius:26px 26px 0 0;z-index:11;padding:12px 22px 28px;box-shadow:0 -14px 44px rgba(0,0,0,.16);}
.sheet .grab{width:38px;height:4px;border-radius:2px;background:#E4E4E8;margin:0 auto 16px;}
.sheet .cell{display:flex;flex-direction:column;align-items:center;gap:7px;font-size:11px;color:var(--ink);width:52px;}
.sheet .ico{width:48px;height:48px;border-radius:16px;background:var(--surface);display:flex;align-items:center;justify-content:center;color:var(--ink);}
.chatmenu{position:absolute;background:#fff;border-radius:18px;box-shadow:0 14px 44px rgba(20,20,20,.2);padding:6px;z-index:12;width:176px;}
.chatmenu .mi{display:flex;align-items:center;gap:12px;padding:11px 12px;font-size:13px;border-radius:12px;}
.chatmenu .mi.on{background:var(--surface);}
.chatmenu.wx{background:rgba(20,20,22,.96);border-radius:14px;box-shadow:0 12px 36px rgba(0,0,0,.35);padding:4px 0;width:148px;}
.chatmenu.wx .mi{color:#fff;font-size:14px;padding:12px 16px;border-radius:0;gap:0;}
.chatmenu.wx .mi.on{background:transparent;}
.chatmenu.wx .mi + .mi{border-top:0.5px solid rgba(255,255,255,.12);}
.bubble-hl{outline:2px solid var(--ink);outline-offset:3px;}
.toast{position:absolute;left:50%;top:118px;transform:translateX(-50%);background:rgba(20,20,20,.88);color:#fff;font-size:12px;border-radius:18px;padding:8px 16px;z-index:9;white-space:nowrap;}
.motion-row{display:flex;align-items:center;gap:12px;padding:12px 0;}
.motion-row .num{width:44px;height:44px;border-radius:14px;background:var(--surface);display:flex;align-items:center;justify-content:center;flex:none;}
.motion-row .info{flex:1;min-width:0;}
.motion-row .info .t{font-size:14px;font-weight:600;}
.motion-row .info .d{font-size:11px;color:var(--sec);margin-top:2px;}
.motion-tag{font-size:10px;font-weight:600;color:var(--ink);background:var(--surface);border-radius:9px;padding:3px 8px;white-space:nowrap;}
.motion-tag.b{background:var(--ink);color:#fff;}

/* ---------- media viewer / player ---------- */
.pbar{height:3px;border-radius:2px;background:rgba(255,255,255,.25);position:relative;overflow:visible;flex:1;}
.pbar .buf{position:absolute;left:0;top:0;bottom:0;width:38%;background:rgba(255,255,255,.45);border-radius:2px;}
.pbar .play{position:absolute;left:0;top:0;bottom:0;width:30%;background:#fff;border-radius:2px;}
.pbar .thumb{position:absolute;top:50%;left:30%;transform:translate(-50%,-50%);width:13px;height:13px;border-radius:50%;background:#fff;box-shadow:0 1px 4px rgba(0,0,0,.4);}
.player-ctrl{display:flex;align-items:center;gap:14px;color:#fff;padding:0 16px;height:56px;}
.vdots{display:flex;gap:4px;align-items:center;}
.vdots i{width:5px;height:5px;border-radius:50%;background:rgba(255,255,255,.4);}
.vdots i.on{width:14px;border-radius:3px;background:#fff;}
.img .b{position:absolute;top:3px;left:3px;width:16px;height:16px;border:2px solid currentColor;border-radius:4px;}
.img .c{position:absolute;top:7px;left:8px;width:3px;height:3px;border-radius:50%;background:currentColor;}
.img .m{position:absolute;top:10px;left:7px;width:9px;height:2px;background:currentColor;transform:rotate(45deg);transform-origin:left center;}
.fs .a{position:absolute;top:3px;left:3px;width:7px;height:7px;border-top:2px solid currentColor;border-left:2px solid currentColor;}
.fs .b{position:absolute;bottom:3px;right:3px;width:7px;height:7px;border-bottom:2px solid currentColor;border-right:2px solid currentColor;}
.rot .c{position:absolute;top:3px;left:3px;width:13px;height:13px;border:2px solid currentColor;border-left-color:transparent;border-radius:50%;}
.rot .a{position:absolute;top:1px;left:14px;width:0;height:0;border-top:3px solid transparent;border-bottom:3px solid transparent;border-left:5px solid currentColor;}
.emoji .c{position:absolute;top:2px;left:2px;width:18px;height:18px;border:2px solid currentColor;border-radius:50%;}
.emoji .e1{position:absolute;top:8px;left:7px;width:2px;height:2px;background:currentColor;border-radius:50%;}
.emoji .e2{position:absolute;top:8px;left:13px;width:2px;height:2px;background:currentColor;border-radius:50%;}
.emoji .m{position:absolute;top:11px;left:7px;width:8px;height:4px;border-bottom:2px solid currentColor;border-radius:0 0 8px 8px;}
.hp .b{position:absolute;top:8px;left:4px;width:14px;height:10px;background:currentColor;border-radius:2px;}
.hp .k{position:absolute;top:4px;left:5px;width:12px;height:9px;border:1.6px solid currentColor;border-radius:3px;}
.hp .s{position:absolute;top:8px;left:10px;width:2px;height:10px;background:currentColor;}
.eface{width:40px;height:40px;border-radius:50%;background:#FFD54F;position:relative;}
.eface i{position:absolute;width:3px;height:3px;border-radius:50%;background:#5D4037;}
.eface i:nth-child(1){top:13px;left:11px}
.eface i:nth-child(2){top:13px;left:26px}
.eface .m{position:absolute;top:20px;left:12px;width:16px;height:8px;border:2px solid #5D4037;border-top:none;border-radius:0 0 10px 10px;}
.eface.o .m{border-radius:10px 10px 0 0;border:2px solid #5D4037;border-bottom:none;top:15px;}
.eface.w .m{width:10px;height:5px;left:15px;border-radius:0 0 8px 8px;}
.eface.x i{display:none;}
.eface.x .m{width:14px;height:6px;left:13px;top:17px;border:2px solid #5D4037;border-radius:3px;}
.func-cell{display:flex;flex-direction:column;align-items:center;gap:6px;font-size:11px;color:var(--ink);}
.func-cell .fc{width:52px;height:52px;border-radius:14px;background:#fff;display:flex;align-items:center;justify-content:center;color:var(--ink);box-shadow:0 1px 3px rgba(0,0,0,.05);}

/* ---------- generic ---------- */
.content{padding:8px 16px 0;}
.h1{font-size:22px;font-weight:700;letter-spacing:-0.4px;}
.h2{font-size:17px;font-weight:700;letter-spacing:-0.2px;}
.h3{font-size:15px;font-weight:600;}
.sec{color:var(--sec);font-size:13px;}
.ter{color:var(--ter);font-size:11px;}
.brandtxt{background:var(--grad);-webkit-background-clip:text;background-clip:text;-webkit-text-fill-color:transparent;color:transparent;}
.row{display:flex;align-items:center;}
.between{justify-content:space-between;}
.gap2{gap:8px}.gap3{gap:12px}.gap4{gap:16px}.gap6{gap:24px}
.mt1{margin-top:4px}.mt2{margin-top:8px}.mt3{margin-top:12px}.mt4{margin-top:16px}.mt6{margin-top:24px}.mt8{margin-top:32px}
.mb2{margin-bottom:8px}.mb3{margin-bottom:12px}.mb4{margin-bottom:16px}
.ellipsis{white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.num{font-variant-numeric:tabular-nums;}

/* buttons */
.btn{height:52px;border-radius:16px;display:flex;align-items:center;justify-content:center;font-size:16px;font-weight:600;color:#fff;}
.btn-black{background:var(--ink);color:#fff;}
.btn-grad{background:var(--grad);color:#fff;}
.btn-ghost{background:var(--surface);color:var(--ink);}
.btn-sm{height:36px;padding:0 14px;border-radius:18px;display:inline-flex;align-items:center;justify-content:center;font-size:13px;font-weight:600;}
.btn-sm.black{background:var(--ink);color:#fff;}
.btn-sm.grad{background:var(--grad);color:#fff;}
.btn-sm.ghost{background:var(--surface);color:var(--ink);}
.btn-sm.outline{border:1px solid var(--line);color:var(--ink);background:#fff;}
.btn-block{width:100%;}

/* fields */
.field{height:52px;border-radius:14px;background:var(--surface);display:flex;align-items:center;padding:0 16px;gap:8px;font-size:15px;}
.field .pre{font-size:15px;font-weight:600;color:var(--ink);}
.field .ph{color:var(--ter);font-size:15px;}
.field .sep{width:1px;height:20px;background:#DADADE;}
.field .act{font-size:13px;font-weight:600;color:var(--ink);}
.field.focus{outline:1.5px solid var(--ink);}
.textarea{min-height:96px;border-radius:14px;background:var(--surface);padding:14px 16px;font-size:15px;color:var(--ink);display:block;width:100%;border:none;outline:none;font-family:var(--font);}
.textarea .ph{color:var(--ter);}

/* chips / seg */
.chip{height:30px;padding:0 12px;border-radius:15px;background:var(--surface);font-size:13px;display:inline-flex;align-items:center;gap:5px;color:var(--ink);flex:none;}
.chip.on{background:var(--ink);color:#fff;}
.chip.grad{background:var(--grad);color:#fff;}
.chip.sm{height:26px;font-size:11px;padding:0 10px;}
.seg{height:40px;border-radius:20px;background:var(--surface);display:flex;padding:3px;}
.seg .item{flex:1;border-radius:17px;display:flex;align-items:center;justify-content:center;font-size:13px;color:var(--sec);}
.seg .item.on{background:#fff;color:var(--ink);font-weight:600;box-shadow:0 1px 4px rgba(0,0,0,.08);}

/* cards */
.card{background:#fff;border:1px solid var(--line);border-radius:16px;overflow:hidden;}
.card-flat{background:var(--surface);border-radius:16px;}
.card-pad{padding:16px;}
.divider{height:1px;background:var(--line);}

/* avatar */
.av{width:40px;height:40px;border-radius:50%;flex:none;overflow:hidden;background:var(--gradsoft);display:flex;align-items:center;justify-content:center;color:#fff;font-size:14px;font-weight:600;}
.av.sm{width:32px;height:32px;font-size:12px;}
.av.lg{width:64px;height:64px;font-size:20px;}
.av.g1{background:linear-gradient(135deg,#36D1DC,#5B86E5);}
.av.g2{background:linear-gradient(135deg,#A18CD1,#FBC2EB);}
.av.g3{background:linear-gradient(135deg,#667EEA,#764BA2);}
.av.g4{background:linear-gradient(135deg,#43E97B,#38F9D7);}
.av.g5{background:linear-gradient(135deg,#396AFC,#2948FF);}
.av.g6{background:linear-gradient(135deg,#834D9B,#D04ED6);}
.ring{background:var(--grad);border-radius:50%;padding:2px;flex:none;}
.ring .inner{background:#fff;border-radius:50%;padding:2px;}

/* photo placeholders */
.photo{position:relative;overflow:hidden;background:var(--gradsoft);}
.photo p1{position:absolute;inset:0;}
.p1{background:linear-gradient(135deg,#667EEA 0%,#764BA2 100%);}
.p2{background:linear-gradient(135deg,#36D1DC 0%,#5B86E5 100%);}
.p3{background:linear-gradient(135deg,#A18CD1 0%,#FBC2EB 100%);}
.p4{background:linear-gradient(135deg,#3A6073 0%,#16222A 100%);}
.p5{background:linear-gradient(135deg,#2C3E50 0%,#4CA1AF 100%);}
.p6{background:linear-gradient(135deg,#834D9B 0%,#D04ED6 100%);}
.p7{background:linear-gradient(135deg,#43E97B 0%,#38F9D7 100%);}
.p8{background:linear-gradient(135deg,#396AFC 0%,#2948FF 100%);}
.p9{background:linear-gradient(135deg,#5B86E5 0%,#36D1DC 100%);}
.p10{background:linear-gradient(160deg,#2B2B33 0%,#1A1A22 60%,#3D2B45 100%);}
.p11{background:linear-gradient(135deg,#7F00FF 0%,#E100FF 100%);}
.p12{background:linear-gradient(135deg,#00B4DB 0%,#0083B0 100%);}
.photo .tagline{position:absolute;left:10px;bottom:10px;color:#fff;font-size:11px;font-weight:600;text-shadow:0 1px 6px rgba(0,0,0,.35);}

/* tab bar (floating pill) */
.tabwrap{position:absolute;left:0;right:0;bottom:0;height:96px;padding:10px 16px 22px;z-index:9;}
.tabpill{height:56px;border-radius:28px;background:#fff;border:1px solid var(--line);box-shadow:0 6px 24px rgba(20,20,20,.08);display:flex;padding:4px;}
.tabitem{flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:3px;border-radius:24px;color:var(--sec);font-size:10px;font-weight:600;}
.tabitem.on{background:var(--grad);color:#fff;}
.tabitem .ic{width:20px;height:20px;}

/* misc */
.badge{min-width:18px;height:18px;border-radius:9px;background:var(--danger);color:#fff;font-size:11px;font-weight:600;display:flex;align-items:center;justify-content:center;padding:0 5px;}
.badge-dot{width:8px;height:8px;border-radius:50%;background:var(--danger);}
.tag{height:22px;padding:0 8px;border-radius:11px;font-size:11px;font-weight:600;display:inline-flex;align-items:center;}
.tag.grad{background:var(--grad);color:#fff;}
.tag.gray{background:var(--surface);color:var(--sec);}
.tag.red{background:#FFEBEE;color:#E53935;}
.tag.green{background:#E8F5E9;color:#2E7D32;}
.tag.blue{background:#E3F2FD;color:#1565C0;}
.switch{width:44px;height:26px;border-radius:13px;background:var(--ink);position:relative;}
.switch:after{content:"";position:absolute;top:3px;right:3px;width:20px;height:20px;border-radius:50%;background:#fff;}
.switch.off{background:#E4E4E8;}
.switch.off:after{right:auto;left:3px;}
.radio{width:20px;height:20px;border-radius:50%;border:2px solid #D1D1D6;position:relative;flex:none;}
.radio.on{border-color:var(--ink);}
.radio.on:after{content:"";position:absolute;top:3px;left:3px;width:10px;height:10px;border-radius:50%;background:var(--ink);}
.stepper{display:flex;align-items:center;gap:20px;}
.stepper .m,.stepper .p{width:36px;height:36px;border-radius:50%;background:var(--surface);display:flex;align-items:center;justify-content:center;font-size:18px;font-weight:600;}
.stepper .n{font-size:18px;font-weight:700;}
.progress{height:4px;border-radius:2px;background:#F0F0F0;overflow:hidden;}
.progress i{display:block;height:100%;background:var(--grad);border-radius:2px;}
.price{font-size:16px;font-weight:700;}
.price .cut{color:var(--ter);font-size:12px;font-weight:400;text-decoration:line-through;}
.listrow{display:flex;align-items:center;gap:12px;padding:14px 0;}
.iconbox{width:40px;height:40px;border-radius:12px;background:var(--surface);display:flex;align-items:center;justify-content:center;flex:none;color:var(--ink);}
.iconbox.grad{background:var(--grad);color:#fff;}
.iconbox.soft{background:var(--gradsoft);color:var(--ink);}
.grid3{display:grid;grid-template-columns:repeat(3,1fr);gap:2px;}
.cell{position:relative;height:124px;overflow:hidden;}
.cell .ov{position:absolute;right:8px;bottom:8px;color:#fff;font-size:11px;font-weight:600;display:flex;align-items:center;gap:4px;text-shadow:0 1px 4px rgba(0,0,0,.4);z-index:2;}
.section-title{display:flex;align-items:center;justify-content:space-between;margin:20px 0 12px;}
.section-title .more{font-size:12px;color:var(--sec);}
.empty{display:flex;flex-direction:column;align-items:center;justify-content:center;gap:10px;padding:48px 0;color:var(--ter);font-size:13px;}
"""

def icon(cls, extra=""):
    return f'<i class="ic {cls} {extra}"></i>'

def statusbar():
    return ('<div class="status"><span class="time">9:41</span>'
            '<div class="sicons">'
            '<div class="sig"><i></i><i></i><i></i><i></i></div>'
            '<div class="wifi"></div><div class="batt"></div>'
            '</div></div>')

def nav(title, right_html="", right_icon=None):
    r = ""
    if right_icon:
        r = f'<div class="rightact">{right_icon}</div>'
    elif right_html:
        r = f'<div class="right">{right_html}</div>'
    return (f'<div class="nav"><div class="back">{icon("bk")}</div>'
            f'<div class="title">{title}</div>{r}</div>')

def tabbar(active):
    items = [
        ("home", "主页"), ("cmp", "社区"), ("reel", "Reels"), ("msg", "聊天"), ("usr", "个人"),
    ]
    html = '<div class="tabwrap"><div class="tabpill">'
    for key, label in items:
        on = " on" if key == active else ""
        cls = {"home":"home","cmp":"cmp","reel":"reel","msg":"msg","usr":"usr"}[key]
        html += f'<div class="tabitem{on}">{icon(cls)}<span>{label}</span></div>'
    html += '</div></div>'
    return html

def chat_input(placeholder="发送消息…", voice_on=False, focused=False, text="", show_send=False):
    voice = ('<div style="background:var(--ink);color:#fff;flex:none;width:34px;height:34px;border-radius:50%;display:flex;align-items:center;justify-content:center;">{icon("mc","ic-sm")}</div>' if voice_on
             else f'<div style="color:var(--sec);flex:none;width:34px;display:flex;justify-content:center;">{icon("mc","ic-sm")}</div>')
    if voice_on:
        mid = '<div style="flex:1;height:42px;border-radius:21px;background:var(--surface);display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:600;color:var(--ink);">按住 说话</div>'
    elif show_send:
        mid = f'<div class="field" style="flex:1;height:42px;border-radius:21px;outline:1.5px solid var(--ink);"><span style="font-size:13px;color:var(--ink);">{text}</span></div>'
    else:
        mid = f'<div class="field" style="flex:1;height:42px;border-radius:21px;"><span class="ph" style="font-size:13px;">{placeholder}</span></div>'
    right = f'<div style="color:var(--sec);flex:none;width:34px;display:flex;justify-content:center;">{icon("emoji","ic-sm")}</div>'
    plus = ('<div class="btn btn-black btn-sm" style="height:36px;">发送</div>' if show_send
            else f'<div style="color:var(--sec);flex:none;width:34px;display:flex;justify-content:center;">{icon("pl","ic-sm")}</div>')
    return f'''<div style="position:absolute;left:0;right:0;bottom:0;height:74px;border-top:1px solid var(--line);background:#fff;display:flex;align-items:center;padding:0 10px;gap:6px;z-index:5;">
      {voice}{mid}{right}{plus}
    </div>'''

def qr_pattern(n=13, cell=14):
    """确定性伪二维码图案（三个定位角 + 时序线 + 伪数据）"""
    cells = []
    def on(r, c):
        # 定位角
        for (cr, cc) in ((0, 0), (0, n - 7), (n - 7, 0)):
            if cr <= r < cr + 7 and cc <= c < cc + 7:
                d = max(abs(r - cr - 3), abs(c - cc - 3))
                return d != 2
        # 时序线
        if r == 6 or c == 6:
            return (r + c) % 2 == 0
        # 伪数据
        return ((r * 31 + c * 17 + (r * c) % 7) % 3) == 0
    size = n * cell
    parts = [f'<div style="width:{size}px;height:{size}px;background:#fff;padding:{cell}px;box-sizing:content-box;">']
    for r in range(n):
        for c in range(n):
            if on(r, c):
                parts.append(f'<div style="position:absolute;left:{c * cell + cell}px;top:{r * cell + cell}px;width:{cell}px;height:{cell}px;background:#141414;"></div>')
    parts.append('</div>')
    return ''.join(parts)

SCREENS = []

def screen(sid, name, body, w=390, h=844):
    SCREENS.append({"sid": sid, "name": name, "body": body, "w": w, "h": h})

# ---------------- 01 登录 ----------------
screen("01", "01-登录", f'''
{statusbar()}
<div class="content">
  <div style="text-align:center;margin:56px 0 40px;">
    <div class="h1 brandtxt" style="font-size:36px;">Think Origin</div>
    <div class="sec" style="margin-top:10px;">发现手作 · 遇见同好</div>
  </div>
  <div class="field mb3"><span class="pre">+86</span><span class="sep"></span><span class="ph">请输入手机号</span></div>
  <div class="field mb3"><span class="ph">请输入验证码</span><span style="flex:1"></span><span class="act">获取验证码</span></div>
  <div class="btn btn-grad btn-block mt4">登录 / 注册</div>
  <div class="row between mt4" style="padding:0 8px;">
    <span class="sec">密码登录</span><span class="sec">忘记密码</span>
  </div>
</div>
<div style="position:absolute;bottom:26px;left:0;right:0;text-align:center;color:var(--ter);font-size:11px;">登录即代表同意《用户协议》和《隐私政策》</div>
''')

# ---------------- 02 设置密码 ----------------
screen("02", "02-设置密码", f'''
{statusbar()}
{nav("设置密码")}
<div class="content">
  <div class="sec mb4" style="margin-top:8px;">设置密码后可用手机号或用户名+密码登录</div>
  <div class="field mb3"><span class="pre">+86</span><span class="sep"></span><span class="ph">请输入手机号</span></div>
  <div class="field mb3"><span class="ph">请输入验证码</span><span style="flex:1"></span><span class="act">获取验证码</span></div>
  <div class="field mb3"><span class="ph">设置密码（6-32 位）</span></div>
  <div class="field mb3"><span class="ph">确认密码</span></div>
  <div class="field"><span class="ph">用户名（选填，字母/数字/下划线）</span></div>
  <div class="btn btn-black btn-block mt6">保存</div>
</div>
''')

# ---------------- 65 密码登录 ----------------
screen("65", "65-密码登录", f'''
{statusbar()}
{nav("密码登录")}
<div class="content">
  <div style="text-align:center;margin:36px 0 30px;">
    <div class="h1 brandtxt" style="font-size:30px;">Think Origin</div>
    <div class="sec" style="margin-top:8px;">使用密码登录</div>
  </div>
  <div class="field mb3"><span class="pre">+86</span><span class="sep"></span><span class="ph">请输入手机号 / 用户名</span></div>
  <div class="field mb3"><span class="ph">请输入密码</span><span style="flex:1"></span><span class="act">忘记密码</span></div>
  <div class="btn btn-black btn-block mt4">登录</div>
  <div class="row between mt4" style="padding:0 8px;">
    <span class="sec">验证码登录</span><span class="sec">注册新账号</span>
  </div>
  <div class="ter" style="text-align:center;margin-top:28px;">密码登录支持手机号或用户名 + 密码</div>
</div>
''')

# ---------------- 66 忘记密码 ----------------
screen("66", "66-忘记密码", f'''
{statusbar()}
{nav("忘记密码")}
<div class="content">
  <div class="sec mb4" style="margin-top:8px;">输入绑定的手机号，通过短信验证码重置密码</div>
  <div class="field mb3"><span class="pre">+86</span><span class="sep"></span><span class="ph">请输入手机号</span></div>
  <div class="field mb3"><span class="ph">请输入验证码</span><span style="flex:1"></span><span class="act">获取验证码</span></div>
  <div class="field mb3"><span class="ph">设置新密码（6-32 位）</span></div>
  <div class="field"><span class="ph">确认新密码</span></div>
  <div class="btn btn-black btn-block mt6">重置密码</div>
  <div class="ter" style="text-align:center;margin-top:20px;font-size:12px;">重置成功后可使用新密码登录</div>
</div>
''')

# ---------------- 03 首页 ----------------
def _home_entry(cls, title, desc):
    return f'''<div class="card card-pad" style="flex:1;display:flex;flex-direction:column;gap:8px;height:110px;">
      <div class="iconbox grad" style="width:36px;height:36px;border-radius:11px;">{icon(cls,"ic-sm")}</div>
      <div><div class="h3">{title}</div><div class="ter" style="margin-top:2px;">{desc}</div></div>
    </div>'''

screen("03", "03-首页", f'''
{statusbar()}
<div class="nav">
  <div class="title" style="font-size:20px;"><span class="brandtxt" style="font-weight:800;">Think Origin</span></div>
  <div class="right" style="gap:18px;">{icon("srch")}{icon("bl")}<span class="badge" style="position:absolute;top:2px;right:6px;">3</span></div>
</div>
<div class="content">
  <div class="section-title" style="margin-top:12px;">
    <div class="row gap2"><span class="h1">拼豆</span><span class="tag grad">人气手作</span></div>
    <span class="more">查看全部 ›</span>
  </div>
  <div class="row gap3">
    {_home_entry("pin","预约","附近门店 / 活动")}
    {_home_entry("qrc","到店","核销 · 上钟")}
    {_home_entry("dmd","会员套餐","权益 · 优惠")}
  </div>
  <div class="section-title">
    <span class="h2">敬请期待</span><span class="more">更多精彩即将上线</span>
  </div>
  <div class="row gap3">
    <div class="card-flat" style="flex:1;height:96px;border:1.5px dashed var(--line);border-radius:16px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:6px;color:var(--sec);">
      {icon("reel")}<span style="font-size:12px;">直播专区</span><span class="ter" style="font-size:10px;">敬请期待</span>
    </div>
    <div class="card-flat" style="flex:1;height:96px;border:1.5px dashed var(--line);border-radius:16px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:6px;color:var(--sec);">
      {icon("gft")}<span style="font-size:12px;">手作商城</span><span class="ter" style="font-size:10px;">敬请期待</span>
    </div>
  </div>
  <div class="section-title"><span class="h2">活动推荐</span><span class="more">查看全部 ›</span></div>
  <div class="row gap3" style="overflow:hidden;">
    <div class="photo p1" style="width:196px;height:120px;border-radius:16px;flex:none;">
      <div class="tagline"># 七夕主题拼豆派对</div>
    </div>
    <div class="photo p6" style="width:196px;height:120px;border-radius:16px;flex:none;">
      <div class="tagline"># 新手体验课</div>
    </div>
  </div>
</div>
{tabbar("home")}
''')

# ---------------- 04 门店列表（原"附近门店-地图"，地图相关代码已注释，改为纯门店列表） ----------------
screen("04", "04-门店列表", f'''
{statusbar()}
{nav("门店列表")}
<div class="content" style="padding:4px 16px 8px;">
  <div class="field mb3" style="height:46px;border-radius:23px;">{icon("srch","ic-sm")}<span class="ph">搜索门店 / 活动</span><span style="flex:1"></span><span class="act">搜索</span></div>
  <div class="row gap2">
    <div class="chip on">全部</div><div class="chip">可预约</div><div class="chip">会员价</div>
    <div style="flex:1"></div>{icon("flt","ic-sm")}
  </div>
</div>
<div class="content" style="padding-top:14px;">
  <div class="card card-pad mb3">
    <div class="row between mb2"><span class="h3">拾光手作馆 · 万象城店</span><span class="price" style="font-size:14px;">¥39.9</span></div>
    <div class="row gap2 mb2"><span class="ter">★★★★★ 4.9</span><span class="ter">·</span><span class="ter">09:00-21:00</span></div>
    <div class="row gap2"><span class="tag blue">有会员价</span><span class="tag gray">可预约</span></div>
    <div class="row between mt3"><span class="sec" style="font-size:12px;">上海市静安区南京西路 1266 号</span><div class="btn btn-sm black">预约</div></div>
  </div>
  <div class="card card-pad mb3">
    <div class="row between mb2"><span class="h3">Think Origin旗舰店</span><span class="price" style="font-size:14px;">¥49.9</span></div>
    <div class="row gap2 mb2"><span class="ter">★★★★★ 5.0</span><span class="ter">·</span><span class="ter">10:00-22:00</span></div>
    <div class="row gap2"><span class="tag red">旗舰</span><span class="tag gray">可预约</span></div>
    <div class="row between mt3"><span class="sec" style="font-size:12px;">徐汇区淮海中路 888 号</span><div class="btn btn-sm black">预约</div></div>
  </div>
  <div class="card card-pad">
    <div class="row between mb2"><span class="h3">青藤手作小院</span><span class="price" style="font-size:14px;">¥29.9</span></div>
    <div class="row gap2 mb2"><span class="ter">★★★★★ 4.7</span><span class="ter">·</span><span class="ter">14:00-21:00</span></div>
    <div class="row gap2"><span class="tag blue">有会员价</span><span class="tag gray">可预约</span></div>
    <div class="row between mt3"><span class="sec" style="font-size:12px;">长宁区愚园路 1107 号</span><div class="btn btn-sm black">预约</div></div>
  </div>
</div>
''')

# ---------------- 67 门店搜索（地图相关代码已注释：去掉地图条、距离最近、地图模式） ----------------
screen("67", "67-门店搜索", f'''
{statusbar()}
{nav("搜索门店")}
<div class="content" style="padding:4px 16px 8px;">
  <div class="field" style="height:46px;border-radius:23px;outline:1.5px solid var(--ink);">{icon("srch","ic-sm")}<span style="font-size:13px;color:var(--ink);">拾光手作</span><span style="flex:1"></span><span class="act">搜索</span></div>
  <div class="row gap2 mt3"><span class="chip sm on">全部</span><span class="chip sm">可预约</span><span class="chip sm">会员价</span></div>
</div>
<div class="content" style="padding-top:14px;">
  <div class="row between mb2"><span class="h2">搜索结果 3</span></div>
  <div class="card card-pad mb3">
    <div class="row between mb2"><span class="h3">拾光手作馆 · 万象城店</span><span class="price" style="font-size:14px;">¥39.9</span></div>
    <div class="row gap2 mb2"><span class="ter">★★★★★ 4.9</span><span class="ter">·</span><span class="ter">09:00-21:00</span></div>
    <div class="row gap2"><span class="tag blue">有会员价</span><span class="tag gray">可预约</span></div>
    <div class="row between mt3"><span class="sec" style="font-size:12px;">上海市静安区南京西路 1266 号</span><div class="btn btn-sm black">预约</div></div>
  </div>
  <div class="card card-pad mb3">
    <div class="row between mb2"><span class="h3">Think Origin旗舰店</span><span class="price" style="font-size:14px;">¥49.9</span></div>
    <div class="row gap2 mb2"><span class="ter">★★★★★ 5.0</span><span class="ter">·</span><span class="ter">10:00-22:00</span></div>
    <div class="row gap2"><span class="tag red">旗舰</span><span class="tag gray">可预约</span></div>
    <div class="row between mt3"><span class="sec" style="font-size:12px;">徐汇区淮海中路 888 号</span><div class="btn btn-sm black">预约</div></div>
  </div>
  <div class="row gap2" style="justify-content:center;padding:10px 0 2px;"><span class="ter" style="font-size:11px;">共 3 条结果 · 查看更多</span></div>
</div>
''')

# ---------------- 05 门店详情-预约 ----------------
screen("05", "05-门店详情-预约", f'''
{statusbar()}
{nav("门店详情")}
<div class="content" style="padding:4px 16px 0;">
  <div class="photo p3" style="width:358px;height:150px;border-radius:20px;">
    <!-- 地图相关：距离角标，先注释 -->
    <!-- <div style="position:absolute;right:10px;top:10px;background:rgba(255,255,255,.9);border-radius:12px;padding:3px 10px;font-size:12px;font-weight:600;">距您 1.2km</div> -->
  </div>
  <div class="row between mt3">
    <div><div class="h2">拾光手作馆 · 万象城店</div>
      <div class="row gap2 mt1"><span class="ter">★★★★★ 4.9</span><span class="ter">·</span><span class="ter">09:00-21:00</span></div>
      <div class="ter mt1">上海市静安区南京西路 1266 号</div>
    </div>
  </div>
  <div class="row gap2 mt2"><span class="tag blue">会员 ¥29.9</span><span class="tag gray">门市 ¥39.9</span><span class="tag red">热销</span></div>
  <div class="section-title" style="margin-top:18px;"><span class="h2">选择日期</span></div>
  <div class="row gap2">
    <div class="card-flat" style="width:52px;height:64px;border-radius:14px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;"><span class="ter" style="font-size:10px;">周四</span><span class="h3">06</span><span class="ter" style="font-size:10px;">8月</span></div>
    <div class="card-flat" style="width:52px;height:64px;border-radius:14px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;background:var(--ink);color:#fff;"><span style="font-size:10px;color:rgba(255,255,255,.7);">周五</span><span class="h3">07</span><span style="font-size:10px;color:rgba(255,255,255,.7);">8月</span></div>
    <div class="card-flat" style="width:52px;height:64px;border-radius:14px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;"><span class="ter" style="font-size:10px;">周六</span><span class="h3">08</span><span class="ter" style="font-size:10px;">8月</span></div>
    <div class="card-flat" style="width:52px;height:64px;border-radius:14px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;"><span class="ter" style="font-size:10px;">周日</span><span class="h3">09</span><span class="ter" style="font-size:10px;">8月</span></div>
    <div class="card-flat" style="width:52px;height:64px;border-radius:14px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;"><span class="ter" style="font-size:10px;">周一</span><span class="h3">10</span><span class="ter" style="font-size:10px;">8月</span></div>
  </div>
  <div class="section-title" style="margin-top:16px;"><span class="h2">选择时段</span><span class="more">今日余位充足</span></div>
  <div class="row gap2" style="flex-wrap:wrap;">
    <div class="chip" style="height:34px;">10:00-11:30</div>
    <div class="chip" style="height:34px;">13:00-14:30</div>
    <div class="chip on" style="height:34px;">15:00-16:30</div>
    <div class="chip" style="height:34px;">17:00-18:30</div>
    <div class="chip" style="height:34px;opacity:.45;">19:00-20:30 满</div>
    <div class="chip" style="height:34px;opacity:.45;">20:00-21:30 满</div>
  </div>
  <div class="section-title" style="margin-top:16px;"><span class="h2">到店人数</span></div>
  <div class="card-flat card-pad row between">
    <span class="sec">2 人位 · 最多 6 人</span>
    <div class="stepper"><span class="m">−</span><span class="n">2</span><span class="p">+</span></div>
  </div>
</div>
<div style="position:absolute;left:16px;right:16px;bottom:20px;">
  <div class="row between mb2"><span class="sec">已选：08-07 周五 15:00-16:30 · 2 人</span></div>
  <div class="btn btn-black btn-block">下一步 · 选择桌位</div>
</div>
''')

# ---------------- 05b 门店详情-选择桌位 ----------------
screen("05b", "05-门店详情-选择桌位", f'''
{statusbar()}
{nav("选择桌位")}
<div class="content">
  <div style="text-align:center;padding:6px 0 4px;"><span class="ter" style="font-size:10px;">· 接上一页 ·</span></div>
  <div class="card card-pad mb4">
    <div class="row between mb2"><span class="sec">门店</span><span class="h3" style="font-size:14px;">拾光手作馆 · 万象城店</span></div>
    <div class="row between mb2"><span class="sec">日期 / 时段</span><span class="h3" style="font-size:14px;">08-07 周五 15:00-16:30</span></div>
    <div class="row between"><span class="sec">人数</span><span class="h3" style="font-size:14px;">2 人</span></div>
  </div>
  <div class="section-title" style="margin-top:0;"><span class="h2">选择桌位</span><span class="more">同店同桌同时段不重复预约</span></div>
  <div class="grid3" style="gap:10px;grid-template-columns:repeat(4,1fr);">
    <div style="height:52px;border-radius:14px;background:var(--ink);color:#fff;display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:600;">A1</div>
    <div style="height:52px;border-radius:14px;background:var(--surface);display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:600;">A2</div>
    <div style="height:52px;border-radius:14px;background:var(--surface);display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:600;">A3</div>
    <div style="height:52px;border-radius:14px;background:var(--surface);display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:600;">A4</div>
    <div style="height:52px;border-radius:14px;background:var(--surface);display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:600;">B1</div>
    <div style="height:52px;border-radius:14px;background:var(--surface);display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:600;">B2</div>
    <div style="height:52px;border-radius:14px;background:#F0F0F0;color:var(--ter);display:flex;align-items:center;justify-content:center;font-size:13px;">B3 满</div>
    <div style="height:52px;border-radius:14px;background:var(--surface);display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:600;">B4</div>
    <div style="height:52px;border-radius:14px;background:var(--surface);display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:600;">C1</div>
    <div style="height:52px;border-radius:14px;background:var(--surface);display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:600;">C2</div>
    <div style="height:52px;border-radius:14px;background:var(--surface);display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:600;">C3</div>
    <div style="height:52px;border-radius:14px;background:var(--surface);display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:600;">C4</div>
  </div>
  <div class="ter mt4" style="font-size:11px;text-align:center;">已选桌位实时锁定，请尽快确认</div>
</div>
<div style="position:absolute;left:16px;right:16px;bottom:20px;">
  <div class="row between mb2"><span class="sec">会员价 ¥29.9 / 人 × 2</span><span class="price">¥59.8</span></div>
  <div class="btn btn-black btn-block">确认预约</div>
</div>
''')

# ---------------- 06 预约确认 ----------------
screen("06", "06-预约确认", f'''
{statusbar()}
{nav("确认预约")}
<div class="content">
  <div class="card card-pad mb4">
    <div class="row between mb2"><span class="sec">门店</span><span class="h3">拾光手作馆 · 万象城店</span></div>
    <div class="row between mb2"><span class="sec">日期</span><span class="h3">08 月 07 日（周五）</span></div>
    <div class="row between mb2"><span class="sec">时段</span><span class="h3">15:00 - 16:30</span></div>
    <div class="row between mb2"><span class="sec">桌位</span><span class="h3">A1（2 人）</span></div>
    <div class="divider"></div>
    <div class="row between mt2"><span class="sec">备注</span><span class="sec" style="color:var(--ter);">无</span></div>
  </div>
  <div class="section-title" style="margin-top:0;"><span class="h2">优惠券</span><span class="more">可用 3 张 ›</span></div>
  <div class="row gap3">
    <div style="width:170px;height:66px;border-radius:14px;border:1.5px solid var(--line);display:flex;overflow:hidden;">
      <div style="width:64px;background:var(--grad);color:#fff;display:flex;flex-direction:column;align-items:center;justify-content:center;"><span style="font-size:17px;font-weight:700;">¥10</span></div>
      <div style="flex:1;padding:8px 10px;"><div style="font-size:12px;font-weight:600;">满 39 可用</div><div class="ter" style="font-size:10px;">08-20 到期</div></div>
    </div>
    <div style="width:170px;height:66px;border-radius:14px;border:1.5px dashed var(--line);display:flex;align-items:center;justify-content:center;color:var(--sec);font-size:12px;">不使用</div>
  </div>
  <div class="section-title" style="margin-top:16px;"><span class="h2">支付方式</span></div>
  <div class="card card-pad">
    <div class="row between mb3"><div class="row gap3"><span class="iconbox grad" style="width:34px;height:34px;border-radius:10px;">{icon("msg","ic-sm")}</span><span class="h3">微信支付</span></div><span class="radio on"></span></div>
    <div class="divider"></div>
    <div class="row between mt3"><div class="row gap3"><span class="iconbox" style="width:34px;height:34px;border-radius:10px;">{icon("wal","ic-sm")}</span><span class="h3">支付宝</span></div><span class="radio"></span></div>
  </div>
  <div class="card-flat card-pad mt4">
    <div class="row between mb2"><span class="sec">原价</span><span class="sec">¥79.8</span></div>
    <div class="row between mb2"><span class="sec">会员优惠</span><span class="sec" style="color:var(--ok);">-¥20.0</span></div>
    <div class="row between mb2"><span class="sec">优惠券</span><span class="sec" style="color:var(--ok);">-¥10.0</span></div>
    <div class="divider"></div>
    <div class="row between mt2"><span class="h3">应付金额</span><span class="price" style="font-size:20px;">¥49.8</span></div>
  </div>
</div>
<div style="position:absolute;left:16px;right:16px;bottom:20px;"><div class="btn btn-black btn-block">确认支付 ¥49.8</div></div>
''')

# ---------------- 07 我的预约 ----------------
def _order_card(status, title, meta, sub, extra=""):
    map_color = {"待核销":"tag red","服务中":"tag green","已完成":"tag gray","已取消":"tag gray"}
    return f'''<div class="card card-pad mb3">
      <div class="row between mb2"><span class="h3">{title}</span><span class="{map_color.get(status,'tag gray')}">{status}</span></div>
      <div class="sec mb1">{meta}</div>
      <div class="ter mb2">{sub}</div>
      <div class="divider"></div>
      <div class="row between mt2">{extra}</div>
    </div>'''

screen("07", "07-我的预约", f'''
{statusbar()}
{nav("我的预约")}
<div class="content">
  <div class="seg mb4"><span class="item on">全部</span><span class="item">待核销</span><span class="item">服务中</span><span class="item">已完成</span></div>
  {_order_card("待核销","拾光手作馆 · 万象城店","08-07 周五 15:00-16:30 · A1 · 2人","预约码 830219","")}
  <div class="card-flat card-pad mb3" style="border:1px dashed var(--line);">
    <div class="row between mb2"><span class="h3" style="font-size:22px;letter-spacing:3px;">8 3 0 2 1 9</span><span class="tag grad">到店核销</span></div>
    <div class="sec">出示预约码，店员扫码或输入验证码开始体验</div>
  </div>
  {_order_card("服务中","拾光手作馆 · 万象城店","08-06 今天 14:20 上钟","已体验 45 分钟","")}
  <div class="card-flat card-pad mb3" style="background:#F6F6F8;">
    <div class="row between mb2"><span class="h3">计时中</span><span class="num" style="font-size:22px;font-weight:700;">00:45:12</span></div>
    <div class="progress mb2"><i style="width:62%;"></i></div>
    <div class="row gap3"><div class="btn btn-black btn-sm" style="flex:1;height:42px;">下钟结束</div></div>
  </div>
  {_order_card("已完成","七夕主题拼豆派对 · 活动场次","08-01 周六 14:00-16:00 · 余座 8/20","已完成 · 支付 ¥0（会员免费）","")}
</div>
''')

# ---------------- 08 到店核销-体验 ----------------
screen("08", "08-到店核销-体验", f'''
{statusbar()}
{nav("到店体验")}
<div class="content">
  <div style="background:var(--grad);border-radius:24px;padding:24px 20px;color:#fff;">
    <div class="row between mb2"><span style="font-size:13px;opacity:.85;">拾光手作馆 · 万象城店</span><span class="tag" style="background:rgba(255,255,255,.22);color:#fff;">待核销</span></div>
    <div style="font-size:32px;font-weight:700;letter-spacing:6px;margin:10px 0 2px;">830219</div>
    <div style="font-size:12px;opacity:.8;">08-07 周五 15:00-16:30 · A1 · 2 人</div>
    <div class="row between mt4">
      <div class="btn btn-sm" style="background:rgba(255,255,255,.92);color:var(--ink);height:44px;flex:1;">扫码核销</div>
      <div style="width:12px;"></div>
      <div class="btn btn-sm" style="background:rgba(255,255,255,.2);color:#fff;height:44px;flex:1;border:1px solid rgba(255,255,255,.4);">复制验证码</div>
    </div>
  </div>
  <div class="card card-pad mt4">
    <div class="h2 mb4" style="text-align:center;">体验流程</div>
    <div class="row">
      <div class="row" style="flex-direction:column;align-items:center;gap:6px;flex:1;">
        <div style="width:34px;height:34px;border-radius:50%;background:var(--grad);color:#fff;display:flex;align-items:center;justify-content:center;">{icon("dmd","ic-sm")}</div>
        <span style="font-size:11px;">预约成功</span>
      </div>
      <div style="flex:1;height:2px;background:var(--grad);"></div>
      <div class="row" style="flex-direction:column;align-items:center;gap:6px;flex:1;">
        <div style="width:34px;height:34px;border-radius:50%;background:var(--grad);color:#fff;display:flex;align-items:center;justify-content:center;">{icon("qrc","ic-sm")}</div>
        <span style="font-size:11px;">到店核销</span>
      </div>
      <div style="flex:1;height:2px;background:var(--grad);"></div>
      <div class="row" style="flex-direction:column;align-items:center;gap:6px;flex:1;">
        <div style="width:34px;height:34px;border-radius:50%;background:var(--grad);color:#fff;display:flex;align-items:center;justify-content:center;">{icon("clk","ic-sm")}</div>
        <span style="font-size:11px;">体验中</span>
      </div>
      <div style="flex:1;height:2px;background:var(--line);"></div>
      <div class="row" style="flex-direction:column;align-items:center;gap:6px;flex:1;">
        <div style="width:34px;height:34px;border-radius:50%;background:var(--surface);color:var(--ter);display:flex;align-items:center;justify-content:center;">{icon("fire","ic-sm")}</div>
        <span style="font-size:11px;color:var(--ter);">完成</span>
      </div>
    </div>
  </div>
  <div class="section-title"><span class="h2">体验计时</span></div>
  <div class="card card-pad">
    <div class="row between mb3"><span class="sec">上钟时间</span><span class="num h3">14:20:05</span></div>
    <div class="row between mb3"><span class="sec">下钟时间</span><span class="num h3">—</span></div>
    <div class="row between mb3"><span class="sec">使用时长</span><span class="num h3">00:45:12</span></div>
    <div class="divider"></div>
    <div class="row between mt3">
      <span class="sec">即将完成</span>
      <div class="btn btn-black btn-sm" style="height:40px;">下钟 · 结束体验</div>
    </div>
  </div>
</div>
''')

# ---------------- 71 核销二维码出示 ----------------
screen("71", "71-核销二维码出示", f'''
{statusbar()}
{nav("到店核销", right_html='<span class="sec" style="font-size:13px;">调亮屏幕</span>')}
<div class="content">
  <div class="card card-pad mb4">
    <div class="row between mb2"><span class="h3">拾光手作馆 · 万象城店</span><span class="tag red">待核销</span></div>
    <div class="sec">08-07 周五 15:00-16:30 · A1 · 2 人</div>
  </div>
  <div style="background:var(--gradsoft);border-radius:24px;padding:26px 20px 22px;display:flex;flex-direction:column;align-items:center;">
    <div class="ter" style="font-size:11px;margin-bottom:14px;">出示给店员扫码核销</div>
    <div style="position:relative;width:196px;height:196px;border-radius:18px;background:#fff;box-shadow:0 6px 24px rgba(0,0,0,.10);">
      {qr_pattern(13, 14)}
      <div style="position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);width:36px;height:36px;border-radius:50%;background:var(--ink);color:#fff;display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;">手</div>
    </div>
    <div style="margin-top:16px;text-align:center;">
      <div class="ter" style="font-size:11px;">预约码</div>
      <div style="font-size:24px;font-weight:700;letter-spacing:4px;margin-top:4px;" class="num">830219</div>
    </div>
  </div>
  <div class="row between mt4">
    <div class="row gap2"><span class="badge-dot" style="background:var(--ok);"></span><span class="sec" style="font-size:12px;">二维码每 30 秒自动刷新</span></div>
    <span class="sec" style="font-size:12px;">有效期至 16:30</span>
  </div>
</div>
''')

# ---------------- 72 体验完成（下钟结束） ----------------
screen("72", "72-体验完成", f'''
{statusbar()}
<div class="content" style="text-align:center;padding-top:44px;">
  <div style="width:92px;height:92px;border-radius:50%;background:var(--ink);color:#fff;display:flex;align-items:center;justify-content:center;margin:0 auto 20px;">{icon("tick","ic-lg")}</div>
  <div class="h1" style="font-size:24px;">体验结束</div>
  <div class="sec mt2">已为您记录本次体验时长，欢迎再次光临</div>
  <div class="card card-pad mt6" style="text-align:left;">
    <div class="row between mb2"><span class="sec">门店</span><span class="h3" style="font-size:14px;">拾光手作馆 · 万象城店</span></div>
    <div class="row between mb2"><span class="sec">桌位 / 人数</span><span class="h3" style="font-size:14px;">A1 · 2 人</span></div>
    <div class="row between mb2"><span class="sec">上钟时间</span><span class="num h3" style="font-size:14px;">14:20:05</span></div>
    <div class="row between mb2"><span class="sec">下钟时间</span><span class="num h3" style="font-size:14px;">15:05:17</span></div>
    <div class="divider" style="margin:10px 0;"></div>
    <div class="row between"><span class="h3">使用时长</span><span class="num" style="font-size:20px;font-weight:700;">45 分钟 12 秒</span></div>
  </div>
  <div class="card card-pad mt4" style="text-align:left;">
    <div class="h3 mb2">本次体验如何？</div>
    <div class="row gap2 mb3">
      <div style="width:30px;height:30px;border-radius:9px;background:var(--ink);"></div>
      <div style="width:30px;height:30px;border-radius:9px;background:var(--ink);"></div>
      <div style="width:30px;height:30px;border-radius:9px;background:var(--ink);"></div>
      <div style="width:30px;height:30px;border-radius:9px;background:var(--ink);"></div>
      <div style="width:30px;height:30px;border-radius:9px;background:var(--surface);"></div>
    </div>
    <div class="row gap2" style="flex-wrap:wrap;">
      <span class="chip on" style="height:28px;font-size:12px;">环境好</span><span class="chip" style="height:28px;font-size:12px;">老师耐心</span><span class="chip" style="height:28px;font-size:12px;">材料齐全</span><span class="chip" style="height:28px;font-size:12px;">下次还来</span>
    </div>
  </div>
  <div class="btn btn-ghost btn-block mt6">提交评价</div>
  <div class="row gap3 mt3">
    <div class="btn btn-black" style="flex:1;height:50px;border-radius:16px;">再次预约</div>
    <div class="btn btn-ghost" style="flex:1;height:50px;border-radius:16px;">返回首页</div>
  </div>
</div>
''')

# ---------------- 09 会员中心 ----------------
def _benefit(cls, title, desc):
    return f'''<div class="row gap3" style="padding:12px 0;">
      <div class="iconbox soft">{icon(cls,"ic-sm")}</div>
      <div style="flex:1;"><div class="h3">{title}</div><div class="ter" style="margin-top:2px;">{desc}</div></div>
      {icon("cr","ic-sm")}
    </div>'''

screen("09", "09-会员中心", f'''
{statusbar()}
{nav("会员中心")}
<div class="content">
  <div style="background:var(--grad);border-radius:24px;padding:22px 20px;color:#fff;position:relative;overflow:hidden;">
    <div class="row between">
      <div><div style="font-size:13px;opacity:.85;">手作会员 · 年卡</div>
        <div style="font-size:26px;font-weight:700;margin-top:4px;">M-2026-0088</div></div>
      <div style="text-align:right;"><div style="font-size:11px;opacity:.8;">有效期至</div><div style="font-size:15px;font-weight:600;">2027-08-06</div></div>
    </div>
    <div class="row gap2 mt4">
      <div class="tag" style="background:rgba(255,255,255,.22);color:#fff;">有效</div>
      <div class="tag" style="background:rgba(255,255,255,.22);color:#fff;">剩余 365 天</div>
    </div>
  </div>
  <div class="section-title"><span class="h2">会员权益</span></div>
  <div class="card card-pad" style="padding:4px 16px;">
    {_benefit("wal","会员专属价","预约与到店享会员价，最高省 ¥20/次")}
    <div class="divider"></div>
    {_benefit("gft","专属活动","会员限定活动与双倍积分")}
    <div class="divider"></div>
    {_benefit("tkt","每月优惠券","每月自动发放专属优惠券")}
    <div class="divider"></div>
    {_benefit("fire","生日礼遇","生日当月免费体验一次")}
  </div>
  <div class="section-title"><span class="h2">开通 / 续费</span><span class="more">当前：年卡</span></div>
  <div class="row gap3">
    <div class="card card-pad" style="flex:1;display:flex;flex-direction:column;gap:8px;">
      <div class="sec">月卡</div><div class="price">¥39 <span class="cut">¥49</span></div>
      <div class="ter">30 天</div>
      <div class="btn btn-sm outline">开通</div>
    </div>
    <div class="card card-pad" style="flex:1;display:flex;flex-direction:column;gap:8px;border-color:transparent;background:var(--gradsoft);">
      <div class="row between"><span class="sec">季卡</span><span class="tag grad" style="height:18px;font-size:10px;">推荐</span></div>
      <div class="price">¥99 <span class="cut">¥129</span></div>
      <div class="ter">90 天</div>
      <div class="btn btn-sm grad">开通</div>
    </div>
    <div class="card card-pad" style="flex:1;display:flex;flex-direction:column;gap:8px;">
      <div class="sec">年卡</div><div class="price">¥299 <span class="cut">¥399</span></div>
      <div class="ter">365 天</div>
      <div class="btn btn-sm black">续费</div>
    </div>
  </div>
  <div class="ter" style="text-align:center;margin-top:20px;">会员权益与规则详见《会员服务协议》</div>
</div>
''')

# ---------------- 10 卡包（优惠券 + 会员体验） ----------------
def _coupon(amount, title, meta, btn, disabled=False):
    return f'''<div class="row mb3" style="height:84px;border-radius:16px;border:1px solid var(--line);overflow:hidden;">
      <div style="width:92px;background:var(--grad);color:#fff;display:flex;flex-direction:column;align-items:center;justify-content:center;position:relative;">
        <div style="font-size:26px;font-weight:700;">{amount}</div><div style="font-size:11px;">优惠券</div>
        <div style="position:absolute;right:-6px;top:-6px;width:12px;height:12px;border-radius:50%;background:#fff;"></div>
        <div style="position:absolute;right:-6px;bottom:-6px;width:12px;height:12px;border-radius:50%;background:#fff;"></div>
      </div>
      <div style="flex:1;padding:12px 14px;">
        <div style="font-size:14px;font-weight:600;">{title}</div>
        <div class="ter" style="font-size:11px;margin-top:3px;">{meta}</div>
      </div>
      <div style="display:flex;align-items:center;padding-right:14px;">
        <div class="btn btn-sm {btn}" style="height:30px;font-size:12px;">{("已使用" if btn=="ghost" else "去使用")}</div>
      </div>
    </div>'''

screen("10", "10-卡包-优惠券", f'''
{statusbar()}
{nav("我的卡包")}
<div class="content">
  <div class="seg mb4"><span class="item on">可用 3</span><span class="item">已使用</span><span class="item">已过期</span></div>
  {_coupon("¥10","新人立减券","满 39 元可用 · 08-20 到期","black")}
  {_coupon("¥20","会员专属券","满 79 元可用 · 08-31 到期","black")}
  {_coupon("¥50","周年庆大额券","满 199 元可用 · 09-01 到期","black")}
  <div class="section-title"><span class="h2">会员专属体验</span><span class="more">每月 1 次 ›</span></div>
  <div class="card card-pad">
    <div class="row between mb2">
      <div><div class="h3">创意拼豆体验</div><div class="ter" style="margin-top:2px;">60 分钟 · 含材料包</div></div>
      <div style="text-align:right;"><div class="price">¥0 <span class="cut">¥39</span></div><div class="ter">剩余 1 次</div></div>
    </div>
    <div class="divider" style="margin:10px 0;"></div>
    <div class="row between">
      <div><div class="h3">亲子手作工坊</div><div class="ter" style="margin-top:2px;">90 分钟 · 2 人</div></div>
      <div style="text-align:right;"><div class="price">¥19.9 <span class="cut">¥59</span></div><div class="ter">剩余 1 次</div></div>
    </div>
  </div>
  <div class="btn btn-ghost btn-block mt4">领取更多优惠券</div>
</div>
''')

# ---------------- 11 活动专区 ----------------
def _activity(title, tag, date, addr, price, seats, cls="p2", sessions=""):
    return f'''<div class="card mb3">
      <div class="photo {cls}" style="height:120px;">
        <div class="tag grad" style="position:absolute;left:10px;top:10px;">{tag}</div>
        <div class="tagline">{title}</div>
      </div>
      <div class="card-pad">
        <div class="row between mb2"><span class="h3">{title}</span><span style="font-size:15px;font-weight:700;">{price}</span></div>
        <div class="sec mb1">{date} · {addr}</div>
        <div class="row between mb3"><span class="ter">剩余名额 {seats}</span><span class="tag gray">可预约</span></div>
        {sessions}
      </div>
    </div>'''

screen("11", "11-活动专区", f'''
{statusbar()}
{nav("活动专区")}
<div class="content">
  <div class="photo p9" style="height:140px;border-radius:20px;margin-bottom:16px;">
    <div style="position:absolute;left:16px;bottom:16px;color:#fff;">
      <div style="font-size:20px;font-weight:700;">夏日手作嘉年华</div>
      <div style="font-size:12px;margin-top:4px;">8 月限定 · 会员免费入场</div>
    </div>
  </div>
  {_activity("七夕主题拼豆派对","限会员","08-10 周六 14:00","静安万象城 3F","会员免费", "12/40", "p1",
    '<div class="row gap2" style="flex-wrap:wrap;"><div class="chip sm on">14:00-16:00</div><div class="chip sm">16:30-18:30</div><div class="chip sm">19:00-21:00</div></div>')}
  {_activity("新手入门体验课","人气","08-15 周六 10:00","静安 · 拾光手作馆","¥29.9", "8/20", "p3")}
  <div class="btn btn-ghost btn-block" style="margin-top:4px;">查看更多活动</div>
</div>
''')

# ---------------- 11c 活动专区-续 ----------------
screen("11c", "11-活动专区-续", f'''
{statusbar()}
{nav("活动专区")}
<div class="content">
  <div style="text-align:center;padding:6px 0 4px;"><span class="ter" style="font-size:10px;">· 接上一页 ·</span></div>
  {_activity("亲子手作工坊","双倍积分","08-22 周六 14:00","徐汇 · Think Origin旗舰店","¥59", "16/30", "p6")}
  {_activity("创意拼豆市集","新品","08-30 周日 10:00","浦东 · 滨江大道 1188 号","¥19.9", "40/80", "p2")}
  <div class="btn btn-ghost btn-block">查看更多活动</div>
</div>
''')

# ---------------- 11b 活动详情-预约 ----------------
screen("11b", "11-活动详情-预约", f'''
{statusbar()}
{nav("活动详情")}
<div class="content" style="padding:4px 16px 0;">
  <div class="photo p1" style="height:150px;border-radius:20px;">
    <div class="tag" style="position:absolute;left:10px;top:10px;background:rgba(20,20,20,.78);color:#fff;">限会员</div>
    <div class="tagline">七夕主题拼豆派对 · Think Origin</div>
  </div>
  <div class="h2 mt3">七夕主题拼豆派对</div>
  <div class="sec mt1">08-10 周六 · 静安万象城 3F</div>
  <div class="row gap2 mt2"><span class="tag gray">情侣组队</span><span class="tag gray">双倍积分</span><span class="tag blue">剩余 12/40</span></div>
  <div class="card card-pad mt4" style="display:flex;flex-direction:row;align-items:center;gap:14px;">
    <div style="flex:1;">
      <div class="row between"><span class="sec">门市价</span><span class="sec">¥59.9 / 人</span></div>
      <div class="row between mt2"><span class="h3">会员价</span><span class="row gap2"><span class="price">¥0</span><span class="tag grad" style="height:18px;font-size:10px;">会员免费</span></span></div>
    </div>
  </div>
  <div class="section-title" style="margin-top:10px;"><span class="h2">选择场次</span><span class="more">余位实时更新</span></div>
  <div class="row gap2" style="flex-wrap:wrap;">
    <div class="card-flat" style="width:106px;height:68px;border-radius:14px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;">
      <span class="h3" style="font-size:14px;">14:00</span><span class="ter" style="font-size:10px;">16:00</span><span class="ter" style="font-size:10px;">余 8</span>
    </div>
    <div class="card-flat" style="width:106px;height:68px;border-radius:14px;background:var(--ink);color:#fff;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;">
      <span class="h3" style="font-size:14px;color:#fff;">16:30</span><span style="font-size:10px;color:rgba(255,255,255,.7);">18:30</span><span style="font-size:10px;color:rgba(255,255,255,.7);">余 12</span>
    </div>
    <div class="card-flat" style="width:106px;height:68px;border-radius:14px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;">
      <span class="h3" style="font-size:14px;">19:00</span><span class="ter" style="font-size:10px;">21:00</span><span class="ter" style="font-size:10px;">余 6</span>
    </div>
    <div class="card-flat" style="width:106px;height:68px;border-radius:14px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;opacity:.45;">
      <span class="h3" style="font-size:14px;">21:30</span><span class="ter" style="font-size:10px;">23:00</span><span class="ter" style="font-size:10px;">已满</span>
    </div>
  </div>
  <div class="section-title" style="margin-top:10px;"><span class="h2">到店人数</span></div>
  <div class="card-flat card-pad row between">
    <span class="sec">情侣组队 · 最多 6 人</span>
    <div class="stepper"><span class="m">−</span><span class="n">2</span><span class="p">+</span></div>
  </div>
  <div class="card-flat card-pad mt3 row between">
    <div class="row gap3">{icon("gft","ic-sm")}<span class="sec" style="font-size:13px;">备注（选填）</span></div>
    <span class="ter" style="font-size:12px;">如：两人同行</span>
  </div>
</div>
<div style="position:absolute;left:16px;right:16px;bottom:20px;">
  <div class="row between mb2"><span class="sec">会员 2 人 · 免费</span><span class="price">¥0</span></div>
  <div class="btn btn-black btn-block">立即预约</div>
</div>
''')

# ---------------- 12 社区 ----------------
def _feed_card(av, name, time, tag, imgs, caption, channel):
    media = ""
    if len(imgs) == 1:
        media = f'<div class="photo {imgs[0]}" style="height:240px;border-radius:14px;"></div>'
    else:
        media = f'<div class="grid3" style="grid-template-columns:repeat(2,1fr);gap:2px;border-radius:14px;overflow:hidden;"><div class="photo {imgs[0]}" style="height:150px;"></div><div class="photo {imgs[1]}" style="height:150px;"></div></div>'
    return f'''<div class="card card-pad mb3">
      <div class="row between mb3">
        <div class="row gap2"><div class="ring"><div class="inner"><div class="av sm {av}">{name[0]}</div></div></div>
          <div><div class="h3" style="font-size:14px;">{name}</div><div class="ter">{time}</div></div></div>
        <span class="tag gray">{tag}</span>
      </div>
      {media}
      <div class="row between mt3">
        <div class="row gap4">{icon("hrt")}<span style="font-size:13px;">2.3k</span>{icon("cmt")}<span style="font-size:13px;">86</span>{icon("bmk")}</div>
        {icon("shr")}
      </div>
      <div class="mt2" style="font-size:13px;"><b>{name}</b> {caption}</div>
      <div class="row gap2 mt2"><span class="tag grad" style="height:20px;font-size:10px;">{channel}</span><span class="ter" style="font-size:12px;">#拼豆 #手作 #手工</span></div>
    </div>'''

def _text_post(av, name, time, tag, content, channel, likes="1.2k", cmts="56"):
    return f'''<div class="card card-pad mb3">
      <div class="row between mb3">
        <div class="row gap2"><div class="ring"><div class="inner"><div class="av sm {av}">{name[0]}</div></div></div>
          <div><div class="h3" style="font-size:14px;">{name}</div><div class="ter">{time}</div></div></div>
        <span class="tag gray">{tag}</span>
      </div>
      <div style="font-size:14px;line-height:1.7;">{content}</div>
      <div class="row between mt3">
        <div class="row gap4">{icon("hrt")}<span style="font-size:13px;">{likes}</span>{icon("cmt")}<span style="font-size:13px;">{cmts}</span>{icon("bmk")}</div>
        {icon("shr")}
      </div>
      <div class="row gap2 mt2"><span class="tag grad" style="height:20px;font-size:10px;">{channel}</span><span class="ter" style="font-size:12px;">#拼豆 #手作 #手工</span></div>
    </div>'''

screen("12", "12-社区", f'''
{statusbar()}
<div class="nav">
  <div class="title" style="font-size:20px;"><span class="brandtxt" style="font-weight:800;">社区</span></div>
  <div class="right" style="gap:18px;">{icon("srch")}{icon("pl")}</div>
</div>
<div class="content">
  <div class="seg mb4"><span class="item">关注</span><span class="item on">最新</span><span class="item">热门</span></div>
  {_feed_card("g1","小豆子","12 分钟前","关注","p2","今天终于完成了 2000 颗拼豆的星空图！过程很治愈，附上成品和过程～","#芙宁娜的后花园")}
  <div class="row gap2" style="justify-content:center;padding:8px 0 4px;"><span class="ter" style="font-size:11px;">下拉查看更多作品</span></div>
</div>
{tabbar("cmp")}
''')

# ---------------- 12b 社区-续 ----------------
screen("12b", "12-社区-续", f'''
{statusbar()}
{nav("社区")}
<div class="content">
  <div style="text-align:center;padding:6px 0 4px;"><span class="ter" style="font-size:10px;">· 接上一页 ·</span></div>
  <div class="seg mb4"><span class="item">关注</span><span class="item on">最新</span><span class="item">热门</span></div>
  {_text_post("g4","柠檬精","38 分钟前","同城","整理了一份新手拼豆工具清单：镊子、熨烫纸、图纸打印机、收纳盒，总共不到 200 块就能入门，需要完整清单的姐妹评论区扣 1～","#拼豆研究所")}
  {_text_post("g5","新手村村民","2 小时前","教程","拼豆图纸怎么找？推荐几个免费网站和工具，附详细步骤，纯文字干货帖～","#拼豆星球")}
</div>
{tabbar("cmp")}
''')

# ---------------- 13 作品详情 ----------------
screen("13", "13-作品详情", f'''
{statusbar()}
{nav("作品详情", right_icon=icon("dots"))}
<div class="photo p5" style="height:300px;border-radius:0 0 20px 20px;">
  <div class="tagline">作品 · 星空拼豆 2000 颗</div>
</div>
<div class="content">
  <div class="row between mt3 mb3">
    <div class="row gap4">
      <div class="row gap1">{icon("hrt")}<span class="sec">2.3k</span></div>
      <div class="row gap1">{icon("cmt")}<span class="sec">86</span></div>
      <div class="row gap1">{icon("bmk")}<span class="sec">412</span></div>
    </div>
    {icon("shr")}
  </div>
  <div style="font-size:14px;line-height:1.6;"><b>小豆子</b> 今天终于完成了 2000 颗拼豆的星空图！过程很治愈，附上成品和过程～ #拼豆 #手作 #星空</div>
  <div class="row gap2 mt2"><span class="ter" style="font-size:12px;">📍 上海市 · 拾光手作馆</span><span class="ter" style="font-size:12px;">· 08-06 14:32</span></div>
  <div class="section-title"><span class="h2">评论 86</span><span class="more">只看楼主</span></div>
  <div class="row gap2 mb4">
    <div class="av sm g4">柠</div>
    <div style="flex:1;"><div style="font-size:13px;"><b>柠檬精</b> <span class="sec">· 2 小时前</span></div>
      <div style="font-size:13px;margin-top:2px;">这也太好看了吧！求教程！</div></div>
    <div class="row gap1">{icon("hrt","ic-sm")}<span class="ter">32</span></div>
  </div>
  <div class="row gap2 mb4">
    <div class="av sm g6">阿</div>
    <div style="flex:1;"><div style="font-size:13px;"><b>阿周</b> <span class="sec">· 1 小时前</span></div>
      <div style="font-size:13px;margin-top:2px;">回复 @小豆子：蹲一个材料包链接～</div></div>
    <div class="row gap1">{icon("hrt","ic-sm")}<span class="ter">12</span></div>
  </div>
</div>
<div style="position:absolute;left:0;right:0;bottom:0;height:68px;border-top:1px solid var(--line);background:#fff;display:flex;align-items:center;padding:0 16px;gap:12px;">
  <div class="field" style="flex:1;height:42px;border-radius:21px;"><span class="ph" style="font-size:13px;">说点什么…</span></div>
  <div class="btn btn-black btn-sm" style="height:38px;">发送</div>
</div>
''')

# ---------------- 14 发布作品（微博式） ----------------
screen("14", "14-发布作品-微博风", f'''
{statusbar()}
<div class="nav">
  <div class="back" style="width:56px;font-size:14px;color:var(--sec);padding-left:12px;">取消</div>
  <div class="title" style="font-size:16px;">发微博</div>
  <div class="btn btn-sm black" style="position:absolute;right:12px;height:32px;border-radius:16px;font-size:13px;">发布</div>
</div>
<div class="content">
  <div class="textarea mb3" style="min-height:84px;background:transparent;padding:8px 0;"><span class="ph">分享新鲜事…</span></div>
  <div class="grid3" style="grid-template-columns:repeat(3,1fr);gap:4px;margin-bottom:14px;">
    <div style="height:112px;border-radius:12px;border:1.5px dashed var(--line);display:flex;flex-direction:column;align-items:center;justify-content:center;gap:5px;color:var(--sec);background:var(--surface);">{icon("cam")}<span style="font-size:10px;">拍摄 / 相册</span></div>
    <div class="photo p2" style="height:112px;border-radius:12px;position:relative;"><span style="position:absolute;right:6px;top:6px;width:18px;height:18px;border-radius:50%;background:rgba(0,0,0,.55);color:#fff;display:flex;align-items:center;justify-content:center;">{icon("x","ic-sm")}</span></div>
    <div class="photo p6" style="height:112px;border-radius:12px;"></div>
    <div class="photo p3" style="height:112px;border-radius:12px;"></div>
    <div class="photo p5" style="height:112px;border-radius:12px;"></div>
    <div class="photo p1" style="height:112px;border-radius:12px;"></div>
    <div style="height:112px;border-radius:12px;background:var(--surface);display:flex;align-items:center;justify-content:center;color:var(--ter);">{icon("pl","ic-sm")}</div>
    <div style="height:112px;border-radius:12px;background:var(--surface);"></div>
    <div style="height:112px;border-radius:12px;background:var(--surface);"></div>
  </div>
  <div class="card-flat card-pad" style="padding:10px 16px;">
    <div class="row between" style="padding:9px 0;">
      <div class="row gap3">{icon("pin","ic-sm")}<span class="h3" style="font-size:14px;">所在位置</span></div>
      <span class="sec">添加位置 ›</span>
    </div>
    <div class="divider"></div>
    <div class="row between" style="padding:9px 0;">
      <div class="row gap3">{icon("hash","ic-sm")}<span class="h3" style="font-size:14px;">话题</span></div>
      <span class="sec">#拼豆 #手作 ›</span>
    </div>
    <div class="divider"></div>
    <div class="row between" style="padding:9px 0;">
      <div class="row gap3">{icon("eye","ic-sm")}<span class="h3" style="font-size:14px;">谁可以看</span></div>
      <span class="row gap2"><span class="sec">公开</span>{icon("cr","ic-sm")}</span>
    </div>
    <div class="divider"></div>
    <div class="row between" style="padding:9px 0;">
      <div class="row gap3">{icon("clk","ic-sm")}<span class="h3" style="font-size:14px;">定时微博</span></div>
      <span class="row gap2"><span class="sec">不设</span>{icon("cr","ic-sm")}</span>
    </div>
  </div>
</div>
<div style="position:absolute;left:16px;right:16px;bottom:18px;display:flex;align-items:center;gap:22px;">
  <div class="row gap2" style="flex:1;">{icon("cam","ic-sm")}<span style="font-size:12px;color:var(--sec);">拍摄</span></div>
  <div class="row gap2">{icon("grd","ic-sm")}<span style="font-size:12px;color:var(--sec);">相册</span></div>
  <div class="row gap2">{icon("pen","ic-sm")}<span style="font-size:12px;color:var(--sec);">头条文章</span></div>
  <div class="row gap2">{icon("reel","ic-sm")}<span style="font-size:12px;color:var(--sec);">直播</span></div>
  <div class="row gap2">{icon("dots","ic-sm")}<span style="font-size:12px;color:var(--sec);">更多</span></div>
</div>
''')

# ---------------- 15 用户主页 ----------------
screen("15", "15-用户主页", f'''
{statusbar()}
{nav("小豆子", right_icon=icon("dots"))}
<div class="content">
  <div class="row gap4" style="padding:8px 0 16px;">
    <div class="ring"><div class="inner"><div class="av lg g1">豆</div></div></div>
    <div style="flex:1;display:flex;">
      <div style="flex:1;text-align:center;"><div class="h2">32</div><div class="ter">作品</div></div>
      <div style="flex:1;text-align:center;"><div class="h2">1.2k</div><div class="ter">粉丝</div></div>
      <div style="flex:1;text-align:center;"><div class="h2">86</div><div class="ter">关注</div></div>
    </div>
  </div>
  <div class="h3">小豆子</div>
  <div class="sec mt1">拼豆手作爱好者 | 治愈系手工</div>
  <div class="ter mt1">📍 上海 · 拾光手作馆常客</div>
  <div class="row gap3 mt4">
    <div class="btn btn-black btn-sm" style="flex:1;height:44px;border-radius:14px;">关注</div>
    <div class="btn btn-ghost btn-sm" style="flex:1;height:44px;border-radius:14px;">私信</div>
  </div>
  <div class="row gap2 mt4">
    <div class="chip on">帖子 20</div><div class="chip">笔记 8</div><div class="chip">视频 4</div>
    <div style="flex:1;"></div>{icon("grd","ic-sm")}
  </div>
  <div class="grid3">
    <div class="photo p5 cell"><div class="ov">{icon("hrt","ic-sm")} 2.3k</div></div>
    <div class="photo p1 cell"><div class="ov">{icon("hrt","ic-sm")} 1.1k</div></div>
    <div class="cell" style="background:var(--surface);padding:10px;display:flex;flex-direction:column;justify-content:space-between;">
      <div><div style="font-size:10px;color:var(--ter);">文字帖</div><div style="font-size:11px;font-weight:600;line-height:1.5;margin-top:4px;">新手拼豆工具清单分享，评论区领完整版</div></div>
      <div class="row gap1" style="color:var(--sec);">{icon("hrt","ic-sm")}<span style="font-size:10px;">1.2k</span></div>
    </div>
    <div class="photo p7 cell"><div class="ov">{icon("hrt","ic-sm")} 412</div></div>
    <div class="photo p11 cell"><div class="ov">{icon("hrt","ic-sm")} 398</div></div>
    <div class="photo p3 cell"><div class="ov">{icon("hrt","ic-sm")} 860</div></div>
    <div class="photo p9 cell"><div class="ov">{icon("hrt","ic-sm")} 620</div></div>
  </div>
</div>
''')

# ---------------- 68 用户主页-笔记 ----------------
screen("68", "68-用户主页-笔记", f'''
{statusbar()}
{nav("小豆子", right_icon=icon("dots"))}
<div class="content">
  <div class="row gap4" style="padding:8px 0 16px;">
    <div class="ring"><div class="inner"><div class="av lg g1">豆</div></div></div>
    <div style="flex:1;display:flex;">
      <div style="flex:1;text-align:center;"><div class="h2">32</div><div class="ter">作品</div></div>
      <div style="flex:1;text-align:center;"><div class="h2">1.2k</div><div class="ter">粉丝</div></div>
      <div style="flex:1;text-align:center;"><div class="h2">86</div><div class="ter">关注</div></div>
    </div>
  </div>
  <div class="h3">小豆子</div>
  <div class="sec mt1">拼豆手作爱好者 | 治愈系手工</div>
  <div class="row gap3 mt4">
    <div class="btn btn-black btn-sm" style="flex:1;height:44px;border-radius:14px;">关注</div>
    <div class="btn btn-ghost btn-sm" style="flex:1;height:44px;border-radius:14px;">私信</div>
  </div>
  <div class="row gap2 mt4">
    <div class="chip">帖子 20</div><div class="chip on">笔记 8</div><div class="chip">视频 4</div>
    <div style="flex:1;"></div>{icon("lst","ic-sm")}
  </div>
  <div class="card card-pad mb3">
    <div class="row gap2 mb2"><div class="av sm g1">豆</div><div><div class="h3" style="font-size:13px;">小豆子</div><div class="ter" style="font-size:11px;">08-06 · 笔记</div></div></div>
    <div style="font-size:14px;line-height:1.7;">拼豆新手入门工具清单：镊子、熨烫纸、图纸打印机、收纳盒，不到 200 块搞定，评论区扣 1 发完整清单。</div>
    <div class="row between mt3"><div class="row gap4">{icon("hrt","ic-sm")}<span style="font-size:12px;">1.2k</span>{icon("cmt","ic-sm")}<span style="font-size:12px;">56</span>{icon("bmk","ic-sm")}</div>{icon("shr","ic-sm")}</div>
  </div>
  <div class="card card-pad">
    <div class="row gap2 mb2"><div class="av sm g1">豆</div><div><div class="h3" style="font-size:13px;">小豆子</div><div class="ter" style="font-size:11px;">08-03 · 笔记</div></div></div>
    <div style="font-size:14px;line-height:1.7;">关于拼豆熨烫的温度和时长总结，不同品牌的豆子参数不一样，附我实测的数据表。</div>
    <div class="row between mt3"><div class="row gap4">{icon("hrt","ic-sm")}<span style="font-size:12px;">860</span>{icon("cmt","ic-sm")}<span style="font-size:12px;">42</span>{icon("bmk","ic-sm")}</div>{icon("shr","ic-sm")}</div>
  </div>
</div>
''')

# ---------------- 16 Reels 信息流 ----------------
screen("16", "16-Reels", f'''
<div class="photo p10" style="position:absolute;inset:0;background:linear-gradient(160deg,#2B2B33 0%,#1A1A22 60%,#3D2B45 100%);">
  <div style="position:absolute;inset:0;background:radial-gradient(circle at 70% 30%,rgba(255,255,255,.14),transparent 45%);"></div>
  <div class="status" style="color:#fff;">
    <span class="time" style="color:#fff;">9:41</span>
    <div class="sicons">
      <div class="sig w"><i></i><i></i><i></i><i></i></div>
      <div class="wifi" style="border-color:#fff;"></div>
      <div class="batt" style="border-color:#fff;"></div>
    </div>
  </div>
  <div class="nav">
    <div class="title" style="color:#fff;font-size:16px;"><span style="opacity:.6;">关注</span><span style="margin:0 10px;font-weight:700;">推荐</span><span style="opacity:.6;">本地</span></div>
    <div class="right" style="color:#fff;">{icon("srch","ic-sm")}</div>
  </div>
  <div style="position:absolute;left:16px;bottom:120px;color:#fff;max-width:280px;">
    <div class="row gap2 mb2">
      <div class="ring"><div class="inner"><div class="av sm g2">周</div></div></div>
      <b style="font-size:15px;">@手作阿周</b>
    </div>
    <div style="font-size:13px;line-height:1.6;">3 分钟学会渐变拼豆，新手也能轻松上手 🎨 #拼豆 #手工</div>
    <div class="row gap2 mt2" style="font-size:12px;opacity:.75;">♪ 夏日小夜曲 - Think Origin</div>
  </div>
  <div style="position:absolute;right:12px;bottom:180px;display:flex;flex-direction:column;align-items:center;gap:22px;color:#fff;">
    <div style="display:flex;flex-direction:column;align-items:center;gap:4px;"><div class="ring"><div class="inner"><div class="av sm g5">周</div></div></div><span style="font-size:10px;">关注</span></div>
    <div style="display:flex;flex-direction:column;align-items:center;gap:4px;">{icon("hrt","ic-lg")}<b style="font-size:12px;">12.5w</b></div>
    <div style="display:flex;flex-direction:column;align-items:center;gap:4px;">{icon("cmt","ic-lg")}<b style="font-size:12px;">3.2k</b></div>
    <div style="display:flex;flex-direction:column;align-items:center;gap:4px;">{icon("bmk","ic-lg")}<b style="font-size:12px;">9.8k</b></div>
    <div style="display:flex;flex-direction:column;align-items:center;gap:4px;">{icon("shr","ic-lg")}<b style="font-size:12px;">分享</b></div>
    {icon("dots","ic-lg")}
  </div>
  <div class="tabwrap">
    <div class="tabpill" style="background:rgba(20,20,22,.7);border-color:rgba(255,255,255,.16);box-shadow:none;">
      <div class="tabitem" style="color:rgba(255,255,255,.65);">{icon("home")}<span>主页</span></div>
      <div class="tabitem" style="color:rgba(255,255,255,.65);">{icon("cmp")}<span>社区</span></div>
      <div class="tabitem on" style="color:#fff;">{icon("reel")}<span>Reels</span></div>
      <div class="tabitem" style="color:rgba(255,255,255,.65);">{icon("msg")}<span>聊天</span></div>
      <div class="tabitem" style="color:rgba(255,255,255,.65);">{icon("usr")}<span>个人</span></div>
    </div>
  </div>
</div>
''')

# ---------------- 17 视频详情-评论 ----------------
screen("17", "17-视频详情-评论", f'''
<div class="photo p12" style="height:380px;border-radius:0 0 24px 24px;">
  <div style="position:absolute;inset:0;background:rgba(0,0,0,.25);"></div>
  <div style="position:absolute;left:0;top:0;right:0;" >
    <div class="status"><span class="time" style="color:#fff;">9:41</span>
      <div class="sicons"><div class="sig w"><i></i><i></i><i></i><i></i></div><div class="wifi" style="border-color:#fff;"></div><div class="batt" style="border-color:#fff;"></div></div>
    </div>
    {nav("视频详情", right_icon=icon("dots"))}
  </div>
  <div style="position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);width:64px;height:64px;border-radius:50%;background:rgba(255,255,255,.9);display:flex;align-items:center;justify-content:center;color:#141414;">{icon("py","ic-lg")}</div>
  <div style="position:absolute;left:16px;bottom:14px;color:#fff;font-size:13px;">@手作阿周 · 3 分钟学会渐变拼豆 #拼豆 #手工</div>
</div>
<div class="content">
  <div class="row between mt3 mb3">
    <div class="row gap4">
      <div class="row gap1">{icon("hrt")}<span class="sec">12.5w</span></div>
      <div class="row gap1">{icon("cmt")}<span class="sec">3.2k</span></div>
      <div class="row gap1">{icon("bmk")}<span class="sec">9.8k</span></div>
    </div>
    {icon("shr")}
  </div>
  <div class="section-title"><span class="h2">评论 3,286</span><span class="more">最热</span></div>
  <div class="row gap2 mb4">
    <div class="av sm g1">豆</div>
    <div style="flex:1;"><div style="font-size:13px;"><b>小豆子</b> <span class="sec">· 2 小时前</span></div>
      <div style="font-size:13px;margin-top:2px;">试了！配色绝了，交作业</div></div>
    <div class="row gap1">{icon("hrt","ic-sm")}<span class="ter">1.2k</span></div>
  </div>
  <div class="row gap2 mb4">
    <div class="av sm g3">果</div>
    <div style="flex:1;"><div style="font-size:13px;"><b>果冻</b> <span class="sec">· 3 小时前</span></div>
      <div style="font-size:13px;margin-top:2px;">请问渐变用了几种颜色？</div></div>
    <div class="row gap1">{icon("hrt","ic-sm")}<span class="ter">568</span></div>
  </div>
  <div class="row gap2 mb4">
    <div class="av sm g5">新</div>
    <div style="flex:1;"><div style="font-size:13px;"><b>新手村村民</b> <span class="sec">· 昨天</span></div>
      <div style="font-size:13px;margin-top:2px;">回复 @手作阿周：已三连，蹲更新！</div></div>
    <div class="row gap1">{icon("hrt","ic-sm")}<span class="ter">342</span></div>
  </div>
</div>
<div style="position:absolute;left:0;right:0;bottom:0;height:68px;border-top:1px solid var(--line);background:#fff;display:flex;align-items:center;padding:0 16px;gap:12px;">
  <div class="field" style="flex:1;height:42px;border-radius:21px;"><span class="ph" style="font-size:13px;">说点什么…</span></div>
  <div class="btn btn-black btn-sm" style="height:38px;">发送</div>
</div>
''')

# ---------------- 18 拍摄页（抖音风） ----------------
screen("18", "18-拍摄页-抖音风", f'''
<div style="position:absolute;inset:0;background:linear-gradient(170deg,#23232B 0%,#15151B 70%);">
  <div style="position:absolute;inset:0;background:radial-gradient(circle at 50% 32%,rgba(255,255,255,.10),transparent 46%);"></div>
  <div class="status" style="color:#fff;">
    <span class="time" style="color:#fff;">9:41</span>
    <div class="sicons"><div class="sig w"><i></i><i></i><i></i><i></i></div><div class="wifi" style="border-color:#fff;"></div><div class="batt" style="border-color:#fff;"></div></div>
  </div>
  <div class="nav" style="color:#fff;">
    <div class="back">{icon("x")}</div>
    <div class="title" style="color:#fff;font-size:16px;font-weight:700;">拍摄</div>
    <div class="right" style="gap:16px;">{icon("flash","ic-sm")}{icon("cam","ic-sm")}{icon("dots","ic-sm")}</div>
  </div>
  <div style="position:absolute;right:14px;top:200px;display:flex;flex-direction:column;gap:18px;color:#fff;">
    <div style="display:flex;flex-direction:column;align-items:center;gap:4px;"><div class="camtool">{icon("magic","ic-sm")}</div><span style="font-size:9px;color:rgba(255,255,255,.75);">美化</span></div>
    <div style="display:flex;flex-direction:column;align-items:center;gap:4px;"><div class="camtool">{icon("stk","ic-sm")}</div><span style="font-size:9px;color:rgba(255,255,255,.75);">特效</span></div>
    <div style="display:flex;flex-direction:column;align-items:center;gap:4px;"><div class="camtool">{icon("clk","ic-sm")}</div><span style="font-size:9px;color:rgba(255,255,255,.75);">倒计时</span></div>
    <div style="display:flex;flex-direction:column;align-items:center;gap:4px;"><div class="camtool">{icon("flt","ic-sm")}</div><span style="font-size:9px;color:rgba(255,255,255,.75);">滤镜</span></div>
  </div>
  <div style="position:absolute;left:0;right:0;bottom:0;height:248px;background:linear-gradient(180deg,transparent,rgba(0,0,0,.55));padding:0 0 26px;">
    <div class="row" style="justify-content:center;gap:26px;margin-bottom:22px;color:#fff;">
      <span style="font-size:13px;opacity:.6;">直播</span>
      <span style="font-size:13px;opacity:.6;">分段</span>
      <span style="font-size:15px;font-weight:700;position:relative;">视频<span style="position:absolute;left:50%;bottom:-8px;transform:translateX(-50%);width:20px;height:3px;border-radius:2px;background:#fff;"></span></span>
      <span style="font-size:13px;opacity:.6;">拍照</span>
    </div>
    <div class="row" style="align-items:center;padding:0 30px;">
      <div style="width:58px;display:flex;flex-direction:column;align-items:center;gap:6px;">
        <div class="photo p2" style="width:52px;height:52px;border-radius:10px;border:1.5px solid rgba(255,255,255,.8);"></div>
        <span style="font-size:9px;color:rgba(255,255,255,.75);">最近</span>
      </div>
      <div style="flex:1;display:flex;justify-content:center;">
        <div class="shutter"></div>
      </div>
      <div style="width:58px;display:flex;flex-direction:column;align-items:center;gap:6px;">
        <div style="width:52px;height:52px;border-radius:50%;background:rgba(255,255,255,.14);border:1px solid rgba(255,255,255,.3);display:flex;align-items:center;justify-content:center;position:relative;"><span class="disc" style="position:static;display:block;"></span></div>
        <span style="font-size:9px;color:rgba(255,255,255,.75);">选音乐</span>
      </div>
    </div>
  </div>
</div>
''')

# ---------------- 19 发布视频（抖音风） ----------------
screen("19", "19-发布视频-抖音风", f'''
{statusbar()}
<div class="nav">
  <div class="back">{icon("x")}</div>
  <div class="title" style="font-size:16px;">发布视频</div>
  <div class="btn btn-sm black" style="position:absolute;right:12px;height:32px;border-radius:16px;font-size:13px;">发布</div>
</div>
<div class="content">
  <div class="row gap3 mb3">
    <div class="photo p10" style="width:118px;height:196px;border-radius:14px;flex:none;">
      <div style="position:absolute;inset:0;background:radial-gradient(circle at 55% 35%,rgba(255,255,255,.16),transparent 45%);"></div>
      <div style="position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);width:38px;height:38px;border-radius:50%;background:rgba(255,255,255,.92);display:flex;align-items:center;justify-content:center;color:#141414;">{icon("py","ic-sm")}</div>
      <div style="position:absolute;left:8px;bottom:8px;background:rgba(0,0,0,.45);color:#fff;border-radius:8px;padding:2px 8px;font-size:10px;">00:15 / 00:15</div>
    </div>
    <div style="flex:1;min-width:0;">
      <div class="textarea" style="min-height:76px;"><span class="ph">写一句拍摄心得…</span></div>
      <div class="row gap2 mt3" style="flex-wrap:wrap;">
        <span class="chip sm">#拼豆</span><span class="chip sm">#手工日常</span><span class="chip sm" style="border:1.5px dashed var(--line);background:#fff;color:var(--sec);">+ 话题</span>
      </div>
    </div>
  </div>
  <div class="section-title" style="margin-top:0;"><span class="h2">视频编辑</span></div>
  <div class="row" style="justify-content:space-between;padding:4px 2px 0;position:relative;">
    <div class="editool">{icon("dmd","ic-sm")}<span class="lab">滤镜</span></div>
    <div class="editool">{icon("adj","ic-sm")}<span class="lab">调节</span></div>
    <div class="editool">{icon("clk","ic-sm")}<span class="lab">速度</span></div>
    <div class="editool">{icon("stk","ic-sm")}<span class="lab">特效</span></div>
    <div class="editool">{icon("grd","ic-sm")}<span class="lab">贴纸</span></div>
    <div class="editool">{icon("txt","ic-sm")}<span class="lab">文字</span></div>
    <div class="editool">{icon("mus","ic-sm")}<span class="lab">音乐</span></div>
    <div class="editool">{icon("crop","ic-sm")}<span class="lab">裁剪</span></div>
  </div>
  <div class="card-flat card-pad mt6" style="padding:4px 16px;">
    <div class="row between" style="padding:12px 0;"><div class="row gap3">{icon("hash","ic-sm")}<span class="h3" style="font-size:14px;">添加话题</span></div><span class="sec">+ 添加</span></div>
    <div class="divider"></div>
    <div class="row between" style="padding:12px 0;"><div class="row gap3">{icon("pin","ic-sm")}<span class="h3" style="font-size:14px;">所在位置</span></div><span class="sec">上海 · 拾光手作馆</span></div>
    <div class="divider"></div>
    <div class="row between" style="padding:12px 0;"><div class="row gap3">{icon("eye","ic-sm")}<span class="h3" style="font-size:14px;">谁可以看</span></div><span class="row gap2"><span class="sec">公开</span>{icon("cr","ic-sm")}</span></div>
  </div>
</div>
<div style="position:absolute;left:16px;right:16px;bottom:20px;display:flex;gap:12px;">
  <div class="btn btn-ghost" style="flex:1;height:50px;border-radius:16px;">存草稿</div>
  <div class="btn btn-black" style="flex:1;height:50px;border-radius:16px;">发布</div>
</div>
''')

# ---------------- 20 选择音乐 ----------------
def _music(av, title, artist, dur, hot=False):
    return f'''<div class="row gap3" style="padding:12px 0;">
      <div class="av sm {av}">{title[0]}</div>
      <div style="flex:1;"><div class="row gap2"><span class="h3" style="font-size:14px;">{title}</span>{('<span class="tag red" style="height:16px;font-size:9px;">热</span>' if hot else "")}</div>
        <div class="ter" style="margin-top:2px;">{artist}</div></div>
      <span class="ter num">{dur}</span>
      <span class="btn btn-sm ghost" style="height:28px;font-size:12px;">使用</span>
    </div>'''

screen("20", "20-选择音乐", f'''
{statusbar()}
{nav("选择音乐")}
<div class="content">
  <div class="field mb4">{icon("srch","ic-sm")}<span class="ph">搜索歌名 / 歌手</span></div>
  <div class="section-title" style="margin-top:0;"><span class="h2">热门推荐</span></div>
  <div class="card card-pad" style="padding:4px 16px;">
    {_music("g1","夏日小夜曲","Think Origin", "01:26", True)}
    <div class="divider"></div>
    {_music("g2","手作进行曲","拼豆乐队", "02:03", True)}
    <div class="divider"></div>
    {_music("g3","治愈系咖啡店","Lo-fi 研究所", "01:45", True)}
  </div>
  <div class="section-title"><span class="h2">全部曲库</span><span class="more">共 128 首</span></div>
  <div class="card card-pad" style="padding:4px 16px;">
    {_music("g4","心动信号","小满", "00:58")}
    <div class="divider"></div>
    {_music("g5","深夜手作台","银河漫游", "01:12")}
    <div class="divider"></div>
    {_music("g6","奶油胶之歌","草莓布丁", "00:47")}
  </div>
</div>
<div style="position:absolute;left:0;right:0;bottom:0;height:72px;border-top:1px solid var(--line);background:#fff;display:flex;align-items:center;padding:0 16px;gap:12px;">
  <div class="row gap3" style="flex:1;">{icon("mus")}<div><div class="h3" style="font-size:14px;">夏日小夜曲</div><div class="ter" style="font-size:11px;">Think Origin</div></div></div>
  <div class="btn btn-black btn-sm" style="height:38px;">使用配乐</div>
</div>
''')

# ---------------- 21 会话列表 ----------------
def _conv(av, name, preview, time, unread="", pinned=False, group=False):
    badge = f'<span class="badge" style="min-width:20px;height:20px;">{unread}</span>' if unread else ""
    pin = '<span class="tag gray" style="height:16px;font-size:9px;">置顶</span>' if pinned else ""
    gtag = '<span class="tag blue" style="height:16px;font-size:9px;">群聊</span>' if group else ""
    return f'''<div class="row gap3" style="padding:13px 0;">
      <div class="ring"><div class="inner"><div class="av {av}">{name[0]}</div></div></div>
      <div style="flex:1;min-width:0;">
        <div class="row between"><div class="row gap2">{pin}{gtag}<span class="h3" style="font-size:15px;">{name}</span></div><span class="ter">{time}</span></div>
        <div class="row between mt1"><span class="sec ellipsis" style="max-width:230px;">{preview}</span>{badge}</div>
      </div>
    </div>'''

screen("21", "21-会话列表", f'''
{statusbar()}
<div class="nav">
  <div class="title" style="font-size:20px;font-weight:800;">聊天</div>
  <div class="right">{icon("pl","ic-sm")}</div>
</div>
<div class="content">
  <div class="field mb4">{icon("srch","ic-sm")}<span class="ph">搜索</span></div>
  <div class="card-flat card-pad" style="padding:4px 16px;">
    {_conv("g1","小豆子","[图片] 看我新做的星空拼豆！","14:20","2",True)}
    <div class="divider"></div>
    {_conv("g2","手作同好会","阿周: 今晚 8 点拼豆直播，来呀","13:05","",True,True)}
    <div class="divider"></div>
    {_conv("g3","果冻","语音 12″","12:40","5")}
    <div class="divider"></div>
    {_conv("g4","柠檬精","收到～明天见！","昨天","")}
    <div class="divider"></div>
    {_conv("g5","拼豆研究所","视频 00:15","昨天","")}
  </div>
  <div class="ter" style="text-align:center;margin-top:24px;">— 已展示全部会话 —</div>
</div>
{tabbar("msg")}
''')

# ---------------- 22 单聊 ----------------
screen("22", "22-单聊", f'''
{statusbar()}
{nav("小豆子", right_html='<span class="badge-dot" style="background:var(--ok);"></span>')}
<div style="position:absolute;left:0;right:0;top:106px;bottom:74px;padding:16px;display:flex;flex-direction:column;gap:16px;background:var(--bg);">
  <div style="text-align:center;"><span class="ter" style="font-size:11px;">今天 14:18</span></div>
  <div class="row gap2" style="align-items:flex-start;">
    <div class="av sm g1">豆</div>
    <div style="max-width:250px;background:var(--surface);border-radius:16px 16px 16px 4px;padding:10px 14px;font-size:14px;">今晚要一起拼豆吗？我买了新的星空材料包</div>
  </div>
  <div style="display:flex;justify-content:flex-end;">
    <div style="max-width:250px;background:var(--ink);color:#fff;border-radius:16px 16px 4px 16px;padding:10px 14px;font-size:14px;">好啊！几点？在万象城店吗</div>
  </div>
  <div class="row gap2" style="align-items:flex-start;">
    <div class="av sm g1">豆</div>
    <div style="max-width:250px;background:var(--surface);border-radius:16px 16px 16px 4px;padding:6px;position:relative;">
      <div class="photo p2" style="height:120px;border-radius:12px;"></div>
      <div style="font-size:11px;color:var(--sec);padding:6px 8px 2px;">新到的配色，好看吧</div>
    </div>
  </div>
  <div style="display:flex;justify-content:flex-end;">
    <div style="max-width:250px;background:var(--ink);color:#fff;border-radius:16px 16px 4px 16px;padding:8px 14px;font-size:14px;display:flex;align-items:center;gap:8px;">
      {icon("py","ic-sm")}<span>语音 12″</span>
    </div>
  </div>
  <div style="display:flex;justify-content:flex-end;">
    <div style="max-width:250px;background:var(--ink);color:#fff;border-radius:16px 16px 4px 16px;padding:10px 14px;font-size:14px;">
      <div class="ter" style="font-size:10px;color:rgba(255,255,255,.6);margin-bottom:4px;">引用消息</div>
      已读 14:21
    </div>
  </div>
</div>
{chat_input()}
''')

# ---------------- 23 群聊 ----------------
screen("23", "23-群聊", f'''
{statusbar()}
{nav("手作同好会 (12)", right_html='<div class="row" style="gap:2px;">'+ "".join([f'<div class="av sm {a}" style="width:22px;height:22px;font-size:9px;">{n[0]}</div>' for a,n in [("g1","小"),("g2","阿"),("g3","柠")]]) + '</div>')}
<div style="position:absolute;left:0;right:0;top:106px;bottom:74px;padding:16px;display:flex;flex-direction:column;gap:16px;">
  <div style="text-align:center;"><span class="ter" style="font-size:11px;">今天 13:04</span></div>
  <div style="text-align:center;"><span class="tag gray" style="height:22px;font-size:11px;">小豆子 邀请 阿周 加入了群聊</span></div>
  <div class="row gap2" style="align-items:flex-start;">
    <div class="av sm g2">周</div>
    <div style="max-width:250px;background:var(--surface);border-radius:16px 16px 16px 4px;padding:10px 14px;">
      <div class="ter" style="font-size:11px;color:var(--sec);margin-bottom:4px;">@手作阿周</div>
      <div style="font-size:14px;">今晚 8 点拼豆直播，新手友好，可以来围观！</div>
    </div>
  </div>
  <div style="display:flex;justify-content:flex-end;">
    <div style="max-width:250px;background:var(--grad);color:#fff;border-radius:16px 16px 4px 16px;padding:10px 14px;font-size:14px;">蹲！顺便求个材料包链接</div>
  </div>
  <div class="row gap2" style="align-items:flex-start;">
    <div class="av sm g4">柠</div>
    <div style="max-width:250px;background:var(--surface);border-radius:16px 16px 16px 4px;padding:10px 14px;font-size:14px;">已三连，坐等开播 🎬</div>
  </div>
  <div style="text-align:center;"><span class="tag gray" style="height:22px;font-size:11px;">12 人已读</span></div>
</div>
<div style="position:absolute;left:0;right:0;bottom:0;height:74px;border-top:1px solid var(--line);background:#fff;display:flex;align-items:center;padding:0 12px;gap:10px;">
  <div style="color:var(--sec);">{icon("pl")}</div>
  <div class="field" style="flex:1;height:42px;border-radius:21px;"><span class="ph" style="font-size:13px;">@ 提及成员…</span></div>
  <div style="color:var(--sec);">{icon("mc")}</div>
  <div class="btn btn-grad btn-sm" style="height:38px;">发送</div>
</div>
''')

# ---------------- 24 群设置 ----------------
def _member(av, name, tag="", owner=False):
    return f'''<div class="row" style="flex-direction:column;align-items:center;gap:6px;width:60px;flex:none;">
      <div class="ring"><div class="inner"><div class="av sm {av}">{name[0]}</div></div></div>
      <div class="row gap1"><span style="font-size:11px;">{name}</span></div>
      {('<span class="tag grad" style="height:16px;font-size:9px;">群主</span>' if owner else f'<span class="tag gray" style="height:16px;font-size:9px;">{tag}</span>' if tag else '<span style="height:16px;"></span>')}
    </div>'''

screen("24", "24-群设置", f'''
{statusbar()}
{nav("群聊设置", right_icon=icon("dots"))}
<div class="content">
  <div style="display:flex;flex-direction:column;align-items:center;padding:18px 0 6px;">
    <div class="ring"><div class="inner"><div class="av g2" style="width:64px;height:64px;font-size:20px;">群</div></div></div>
    <div class="h2 mt2">手作同好会</div>
    <div class="ter mt1">群公告：每周三拼豆主题日，欢迎分享作品 🎨</div>
  </div>
  <div class="section-title"><span class="h2">群成员 12</span><span class="more">管理 ›</span></div>
  <div class="row gap3" style="overflow:hidden;padding-bottom:8px;">
    {_member("g1","小豆子",owner=True)}
    {_member("g2","阿周","管理员")}
    {_member("g3","果冻")}
    {_member("g4","柠檬精")}
    {_member("g5","新手村")}
    <div style="width:52px;height:52px;border-radius:50%;border:1.5px dashed var(--line);display:flex;align-items:center;justify-content:center;color:var(--sec);margin-top:2px;">{icon("pl","ic-sm")}</div>
  </div>
  <div class="card-flat card-pad" style="padding:4px 16px;">
    <div class="row between" style="padding:13px 0;"><span class="h3">修改群名称</span><span class="cr" style="color:var(--ter);"></span></div>
    <div class="divider"></div>
    <div class="row between" style="padding:13px 0;"><span class="h3">群公告</span><span class="cr" style="color:var(--ter);"></span></div>
    <div class="divider"></div>
    <div class="row between" style="padding:13px 0;"><span class="h3">消息免打扰</span><span class="switch"></span></div>
    <div class="divider"></div>
    <div class="row between" style="padding:13px 0;"><span class="h3">置顶聊天</span><span class="switch off"></span></div>
  </div>
  <div class="card-flat card-pad mt4" style="background:#FFF7F7;border:1px solid #FFE3E3;">
    <div class="row between" style="padding:8px 0;"><span class="h3" style="color:var(--danger);">退出群聊</span></div>
  </div>
  <div class="ter" style="text-align:center;margin-top:14px;font-size:11px;">群主可解散群聊</div>
</div>
''')

# ---------------- 24b 群成员管理 ----------------
def _mcell(av, name, badge="", remove=False):
    if remove:
        return f'''<div style="width:64px;display:flex;flex-direction:column;align-items:center;gap:6px;flex:none;">
          <div style="position:relative;"><div class="av sm {av}">{name[0]}</div><span style="position:absolute;right:-4px;top:-4px;width:18px;height:18px;border-radius:50%;background:var(--danger);color:#fff;display:flex;align-items:center;justify-content:center;font-size:12px;">−</span></div>
          <span style="font-size:11px;">{name}</span>
        </div>'''
    return f'''<div style="width:64px;display:flex;flex-direction:column;align-items:center;gap:6px;flex:none;">
      <div class="av sm {av}">{name[0]}</div>
      <span style="font-size:11px;">{name}</span>
      {f'<span class="tag grad" style="height:15px;font-size:9px;">{badge}</span>' if badge else '<span style="height:15px;"></span>'}
    </div>'''

screen("24b", "64-群成员管理", f'''
{statusbar()}
{nav("群成员管理", right_html='<span class="sec" style="font-size:13px;">12 人</span>')}
<div class="content">
  <div class="row gap3 card-flat card-pad mb4">
    <div class="ring"><div class="inner"><div class="av g2" style="width:48px;height:48px;font-size:16px;">群</div></div></div>
    <div style="flex:1;min-width:0;">
      <div class="h3">手作同好会</div>
      <div class="ter ellipsis" style="margin-top:2px;">群公告：每周三拼豆主题日，欢迎分享作品</div>
    </div>
    <span class="chip sm">修改</span>
  </div>
  <div class="section-title" style="margin-top:0;"><span class="h2">群成员 12</span><span class="more">长按成员可单独管理</span></div>
  <div class="card card-pad">
    <div class="row" style="justify-content:space-between;margin-bottom:14px;">
      {_mcell("g1","小豆子","群主")}{_mcell("g2","阿周","管理员")}{_mcell("g3","果冻")}{_mcell("g4","柠檬精")}{_mcell("g5","新手村")}
    </div>
    <div class="row" style="justify-content:space-between;margin-bottom:14px;">
      {_mcell("g6","研究所")}{_mcell("g1","小满")}{_mcell("g2","布丁")}{_mcell("g3","星河")}{_mcell("g4","阿紫")}
    </div>
    <div class="row" style="justify-content:space-between;">
      {_mcell("g5","豆丁")}{_mcell("g6","小雨")}
      <div style="width:64px;display:flex;flex-direction:column;align-items:center;gap:6px;flex:none;">
        <div style="width:44px;height:44px;border-radius:50%;border:1.5px dashed var(--line);display:flex;align-items:center;justify-content:center;color:var(--sec);">{icon("pl","ic-sm")}</div>
        <span style="font-size:11px;color:var(--sec);">添加</span>
      </div>
      <div style="width:64px;display:flex;flex-direction:column;align-items:center;gap:6px;flex:none;">
        <div style="width:44px;height:44px;border-radius:50%;background:#FFF0F0;display:flex;align-items:center;justify-content:center;color:var(--danger);">{icon("trash","ic-sm")}</div>
        <span style="font-size:11px;color:var(--danger);">删除</span>
      </div>
    </div>
  </div>
  <div class="section-title" style="margin-top:16px;"><span class="h2">群主管理</span></div>
  <div class="card card-pad" style="padding:4px 16px;">
    <div class="row between" style="padding:13px 0;"><div class="row gap3">{icon("pen","ic-sm")}<span class="h3" style="font-size:14px;">修改群名称</span></div>{icon("cr","ic-sm")}</div>
    <div class="divider"></div>
    <div class="row between" style="padding:13px 0;"><div class="row gap3">{icon("txt","ic-sm")}<span class="h3" style="font-size:14px;">群公告</span></div>{icon("cr","ic-sm")}</div>
    <div class="divider"></div>
    <div class="row between" style="padding:13px 0;"><div class="row gap3">{icon("usr","ic-sm")}<span class="h3" style="font-size:14px;">群主转让</span></div>{icon("cr","ic-sm")}</div>
  </div>
  <div class="card card-pad mt4" style="padding:4px 16px;background:#FFF7F7;border-color:#FFE3E3;">
    <div class="row between" style="padding:13px 0;"><div class="row gap3">{icon("trash","ic-sm")}<span class="h3" style="font-size:14px;color:var(--danger);">解散群聊</span></div></div>
  </div>
  <div class="ter" style="text-align:center;margin-top:14px;font-size:11px;">群主可添加 / 删除成员、转让群主或解散群聊</div>
</div>
''')

# ---------------- 25 添加好友 ----------------
def _person(av, name, meta, btn):
    return f'''<div class="row gap3" style="padding:12px 0;">
      <div class="av {av}">{name[0]}</div>
      <div style="flex:1;"><div class="h3" style="font-size:14px;">{name}</div><div class="ter">{meta}</div></div>
      {btn}
    </div>'''

screen("25", "25-添加好友", f'''
{statusbar()}
{nav("添加好友")}
<div class="content">
  <div class="seg mb4"><span class="item on">手机号搜索</span><span class="item">我的关注</span></div>
  <div class="field mb4">{icon("srch","ic-sm")}<span class="ph">输入对方手机号</span><span style="flex:1"></span><span class="act">搜索</span></div>
  <div class="card card-pad">
    {_person("g4","柠檬精","138****2211 · 上海",'<div class="btn btn-sm black">添加</div>')}
    <div class="divider"></div>
    {_person("g2","手作阿周","已互相关注 · 上海",'<div class="btn btn-sm ghost">已添加</div>')}
  </div>
  <div class="section-title"><span class="h2">发起群聊</span><span class="more">勾选好友 ›</span></div>
  <div class="card card-pad" style="padding:4px 16px;">
    {_person("g1","小豆子","已选择",'<span class="radio on"></span>')}
    <div class="divider"></div>
    {_person("g2","手作阿周","已选择",'<span class="radio on"></span>')}
    <div class="divider"></div>
    {_person("g3","果冻","未选择",'<span class="radio"></span>')}
    <div class="divider"></div>
    {_person("g5","新手村村民","未选择",'<span class="radio"></span>')}
  </div>
  <div class="btn btn-black btn-block mt4">创建群聊（2 人）</div>
</div>
''')

# ---------------- 26 我的主页（功能入口收进右上角菜单） ----------------
def _my_profile_base():
    return f'''
<div class="nav">
  <div class="title" style="font-size:20px;font-weight:800;">我的</div>
  <div class="right">{icon("menu")}</div>
</div>
<div class="content">
  <div class="row gap4" style="padding:8px 0 16px;">
    <div class="ring"><div class="inner"><div class="av lg g1">我</div></div></div>
    <div style="flex:1;display:flex;">
      <div style="flex:1;text-align:center;"><div class="h2">32</div><div class="ter">作品</div></div>
      <div style="flex:1;text-align:center;"><div class="h2">86</div><div class="ter">粉丝</div></div>
      <div style="flex:1;text-align:center;"><div class="h2">1.2k</div><div class="ter">获赞</div></div>
    </div>
  </div>
  <div class="h3">小豆子</div>
  <div class="sec mt1">@xiaodouzi · 拼豆手作爱好者</div>
  <div class="ter mt1">Think Origin 2026 年 6 月入驻 · 上海</div>
  <div class="row gap3 mt4">
    <div class="btn btn-black btn-sm" style="flex:1;height:44px;border-radius:14px;">编辑资料</div>
    <div class="btn btn-ghost btn-sm" style="flex:1;height:44px;border-radius:14px;">分享主页</div>
  </div>
  <div class="row gap2 mt4">
    <div class="chip on">帖子 20</div><div class="chip">笔记 8</div><div class="chip">视频 4</div>
    <div style="flex:1;"></div>{icon("grd","ic-sm")}
  </div>
  <div class="grid3">
    <div class="photo p5 cell"><div class="ov">{icon("hrt","ic-sm")} 2.3k</div></div>
    <div class="photo p1 cell"><div class="ov">{icon("hrt","ic-sm")} 1.1k</div></div>
    <div class="cell" style="background:var(--surface);padding:10px;display:flex;flex-direction:column;justify-content:space-between;">
      <div><div style="font-size:10px;color:var(--ter);">文字帖</div><div style="font-size:11px;font-weight:600;line-height:1.5;margin-top:4px;">新手拼豆工具清单分享，评论区领完整版</div></div>
      <div class="row gap1" style="color:var(--sec);">{icon("hrt","ic-sm")}<span style="font-size:10px;">1.2k</span></div>
    </div>
    <div class="photo p7 cell"><div class="ov">{icon("hrt","ic-sm")} 412</div></div>
    <div class="photo p11 cell"><div class="ov">{icon("hrt","ic-sm")} 398</div></div>
    <div class="photo p3 cell"><div class="ov">{icon("hrt","ic-sm")} 860</div></div>
    <div class="photo p9 cell"><div class="ov">{icon("hrt","ic-sm")} 620</div></div>
  </div>
</div>
{tabbar("usr")}'''

def _my_profile_drawer():
    return f'''
<div style="position:absolute;inset:0;background:rgba(20,20,20,.35);z-index:10;"></div>
<div style="position:absolute;top:0;right:0;bottom:0;width:304px;background:#fff;border-radius:24px 0 0 24px;z-index:11;box-shadow:-8px 0 32px rgba(0,0,0,.14);padding:18px 8px 22px;display:flex;flex-direction:column;">
  <div class="row between" style="padding:4px 10px 14px;">
    <span class="h2" style="font-size:18px;">我的服务</span>
    <span style="width:32px;height:32px;border-radius:50%;background:var(--surface);display:flex;align-items:center;justify-content:center;">{icon("x","ic-sm")}</span>
  </div>
  <div class="row gap3" style="padding:13px 10px;">
    <div class="iconbox soft">{icon("tkt","ic-sm")}</div>
    <div style="flex:1;"><div class="h3" style="font-size:15px;">我的卡包</div><div class="ter">优惠券 · 会员体验</div></div>
    {icon("cr","ic-sm")}
  </div>
  <div class="divider" style="margin:0 10px;"></div>
  <div class="row gap3" style="padding:13px 10px;">
    <div class="iconbox soft">{icon("dmd","ic-sm")}</div>
    <div style="flex:1;"><div class="h3" style="font-size:15px;">点赞与收藏</div><div class="ter">我喜欢的作品</div></div>
    {icon("cr","ic-sm")}
  </div>
  <div class="divider" style="margin:0 10px;"></div>
  <div class="row gap3" style="padding:13px 10px;">
    <div class="iconbox soft">{icon("eye")}</div>
    <div style="flex:1;"><div class="h3" style="font-size:15px;">观看历史</div><div class="ter">作品 · 视频浏览记录</div></div>
    {icon("cr","ic-sm")}
  </div>
  <div class="divider" style="margin:0 10px;"></div>
  <div class="row gap3" style="padding:13px 10px;">
    <div class="iconbox soft">{icon("wal","ic-sm")}</div>
    <div style="flex:1;"><div class="h3" style="font-size:15px;">我的订单</div><div class="ter">预约 · 体验记录</div></div>
    {icon("cr","ic-sm")}
  </div>
  <div class="divider" style="margin:0 10px;"></div>
  <div class="row gap3" style="padding:13px 10px;">
    <div class="iconbox soft">{icon("gear")}</div>
    <div style="flex:1;"><div class="h3" style="font-size:15px;">设置</div><div class="ter">账号与安全 · 通用</div></div>
    {icon("cr","ic-sm")}
  </div>
  <div style="flex:1;"></div>
  <div class="ter" style="text-align:center;font-size:11px;">更多服务持续上线</div>
</div>'''

screen("26", "26-我的主页", f'''
{statusbar()}
{_my_profile_base()}
''')

screen("26b", "26-我的主页-菜单", f'''
{statusbar()}
{_my_profile_base()}
{_my_profile_drawer()}
''')

# ---------------- 27 点赞与收藏 ----------------
screen("27", "27-点赞与收藏", f'''
{statusbar()}
{nav("点赞与收藏")}
<div class="content">
  <div class="seg mb3"><span class="item on">作品点赞</span><span class="item">作品收藏</span><span class="item">视频点赞</span></div>
  <div class="row between mb3"><span class="sec">共 128 条 · 按时间排序</span><span class="chip sm" style="height:26px;">管理</span></div>
  <div class="grid3">
    <div class="photo p5 cell"><div class="ov">{icon("hrt","ic-sm")} 2.3k</div></div>
    <div class="photo p1 cell"><div class="ov">{icon("hrt","ic-sm")} 1.1k</div></div>
    <div class="photo p3 cell"><div class="ov">{icon("hrt","ic-sm")} 860</div></div>
    <div class="photo p9 cell"><div class="ov">{icon("hrt","ic-sm")} 620</div></div>
    <div class="photo p7 cell"><div class="ov">{icon("hrt","ic-sm")} 412</div></div>
    <div class="photo p11 cell"><div class="ov">{icon("hrt","ic-sm")} 398</div></div>
    <div class="photo p2 cell"><div class="ov">{icon("hrt","ic-sm")} 366</div></div>
    <div class="photo p6 cell"><div class="ov">{icon("hrt","ic-sm")} 299</div></div>
    <div class="photo p4 cell"><div class="ov">{icon("hrt","ic-sm")} 251</div></div>
  </div>
  <div class="ter" style="text-align:center;margin-top:20px;">— 已经到底啦 —</div>
</div>
''')

# ---------------- 28 编辑资料 ----------------
screen("28", "28-编辑资料", f'''
{statusbar()}
{nav("编辑资料", right_html='<span class="btn btn-sm black" style="height:32px;">保存</span>')}
<div class="content">
  <div style="display:flex;justify-content:center;padding:12px 0 20px;">
    <div style="position:relative;">
      <div class="ring"><div class="inner"><div class="av g1" style="width:80px;height:80px;font-size:26px;">我</div></div></div>
      <div style="position:absolute;right:-2px;bottom:-2px;width:30px;height:30px;border-radius:50%;background:var(--ink);color:#fff;display:flex;align-items:center;justify-content:center;border:2px solid #fff;">{icon("cam","ic-sm")}</div>
    </div>
  </div>
  <div class="field mb3"><span class="pre">昵称</span><span class="ph" style="margin-left:8px;">小豆子</span></div>
  <div class="field mb3"><span class="pre">用户名</span><span class="ph" style="margin-left:8px;">xiaodouzi</span></div>
  <div class="ter" style="margin:-4px 4px 12px;">用户名一年内只能修改一次，设置后可用于用户名+密码登录</div>
  <div class="textarea mb3" style="min-height:80px;"><span class="ph">简介：拼豆手作爱好者，治愈系手工</span></div>
  <div class="card-flat card-pad mb3">
    <div class="row between mb3"><span class="h3">性别</span><span class="sec">女</span></div>
    <div class="divider"></div>
    <div class="row between mt3 mb3"><span class="h3">生日</span><span class="sec">1999-08-06</span></div>
    <div class="divider"></div>
    <div class="row between mt3"><span class="h3">所在地</span><span class="sec">上海市</span></div>
  </div>
</div>
''')

# ---------------- 29 我的内容 ----------------
def _cell(photo, ov_html):
    return f'<div class="photo {photo} cell">{ov_html}</div>'

screen("29", "29-我的内容", f'''
{statusbar()}
{nav("我的内容")}
<div class="content">
  <div class="seg mb4"><span class="item on">作品</span><span class="item">视频</span><span class="item">点赞</span><span class="item">收藏</span><span class="item">历史</span></div>
  <div class="grid3">
    {_cell("p5",f'<div class="ov">{icon("hrt","ic-sm")} 2.3k</div>')}
    {_cell("p1",f'<div class="ov">{icon("hrt","ic-sm")} 1.1k</div>')}
    {_cell("p3",f'<div class="ov">{icon("hrt","ic-sm")} 860</div>')}
    {_cell("p9",f'<div class="ov">{icon("hrt","ic-sm")} 620</div>')}
    {_cell("p7",f'<div class="ov">{icon("hrt","ic-sm")} 412</div>')}
    {_cell("p11",f'<div class="ov">{icon("hrt","ic-sm")} 398</div>')}
    {_cell("p2",f'<div class="ov">{icon("py","ic-sm")} 3.6w</div>')}
    {_cell("p6",f'<div class="ov">{icon("py","ic-sm")} 2.1w</div>')}
    {_cell("p4",f'<div class="ov">{icon("py","ic-sm")} 1.4w</div>')}
  </div>
  <div class="ter" style="text-align:center;margin-top:20px;">共 32 个作品 · 3 个视频</div>
</div>
''')

# ---------------- 30 我的订单 ----------------
def _order(status_color, status, title, meta, sub, price=""):
    return f'''<div class="card card-pad mb3">
      <div class="row between mb2"><span class="h3">{title}</span><span class="tag {status_color}">{status}</span></div>
      <div class="sec mb1">{meta}</div>
      <div class="ter mb2">{sub}</div>
      <div class="divider"></div>
      <div class="row between mt2">
        <span class="price" style="font-size:14px;">{price}</span>
        <div class="row gap2"><span class="btn btn-sm ghost" style="height:30px;font-size:12px;">详情</span><span class="btn btn-sm black" style="height:30px;font-size:12px;">查看码</span></div>
      </div>
    </div>'''

screen("30", "30-我的订单", f'''
{statusbar()}
{nav("我的订单")}
<div class="content">
  <div class="seg mb4" style="overflow:hidden;"><span class="item on">全部</span><span class="item">待核销</span><span class="item">服务中</span><span class="item">已完成</span><span class="item">已取消</span></div>
  {_order("red","待核销","拾光手作馆 · 万象城店","08-07 周五 15:00-16:30 · A1 · 2 人","预约码 830219 · 微信支付","¥49.8")}
  {_order("green","服务中","拾光手作馆 · 万象城店","08-06 今天 14:20-15:05 · A1 · 2 人","已体验 45 分钟","¥49.8")}
  {_order("gray","已完成","七夕主题拼豆派对","08-01 周六 14:00-16:00 · 活动场次","会员免费 · 已核销","¥0.00")}
  <div class="row gap2" style="justify-content:center;padding:6px 0 2px;"><span class="ter" style="font-size:11px;">下拉查看更多订单</span></div>
</div>
''')

# ---------------- 30b 我的订单-续 ----------------
screen("30b", "30-我的订单-续", f'''
{statusbar()}
{nav("我的订单")}
<div class="content">
  <div style="text-align:center;padding:6px 0 4px;"><span class="ter" style="font-size:10px;">· 接上一页 ·</span></div>
  <div class="seg mb4" style="overflow:hidden;"><span class="item on">全部</span><span class="item">待核销</span><span class="item">服务中</span><span class="item">已完成</span><span class="item">已取消</span></div>
  {_order("gray","已完成","拾光手作馆 · 大悦城店","07-20 周日 10:00-11:30 · B2 · 1 人","已完成 · 支付宝","¥39.9")}
  {_order("gray","已取消","新手入门体验课","07-12 周六 10:00 · 活动场次","用户取消 · 已退款","¥29.9")}
  {_order("gray","已取消","亲子手作工坊","07-05 周日 14:00 · 活动场次","超时未支付 · 已取消","¥59.0")}
</div>
''')

# ---------------- 31 通知 ----------------
def _notice(icon_cls, title, time, content, unread=False):
    dot = '<span class="badge-dot" style="position:absolute;top:16px;right:16px;"></span>' if unread else ""
    return f'''<div style="position:relative;padding:14px 0;">
      <div class="row gap3">
        <div class="iconbox soft">{icon(icon_cls,"ic-sm")}</div>
        <div style="flex:1;min-width:0;">
          <div class="row between"><span class="h3" style="font-size:14px;">{title}</span><span class="ter">{time}</span></div>
          <div class="sec mt1" style="font-size:13px;">{content}</div>
        </div>
      </div>
      {dot}
    </div>'''

screen("31", "31-通知", f'''
{statusbar()}
{nav("通知", right_html='<span class="sec" style="font-size:13px;">全部已读</span>')}
<div class="content">
  <div class="row gap3 mb2"><span class="h2">互动</span><span class="badge">3</span></div>
  <div class="card card-pad" style="padding:4px 16px;">
    {_notice("hrt","小豆子 赞了你的作品","刚刚","「星空拼豆 2000 颗」获赞 +1",True)}
    <div class="divider"></div>
    {_notice("cmt","果冻 评论了你","8 分钟前","「配色太绝了！求教程」",True)}
    <div class="divider"></div>
    {_notice("usr","手作阿周 关注了你","1 小时前","快去 TA 的主页看看吧",True)}
    <div class="divider"></div>
    {_notice("bmk","柠檬精 收藏了你的作品","2 小时前","「渐变拼豆教程」被收藏")}
  </div>
  <div class="section-title"><span class="h2">系统消息</span></div>
  <div class="card card-pad" style="padding:4px 16px;">
    {_notice("gft","会员权益已到账","昨天","您的 8 月会员优惠券已发放至卡包")}
    <div class="divider"></div>
    {_notice("clk","预约即将开始","昨天","明天 15:00 拾光手作馆体验即将开始")}
    <div class="divider"></div>
    {_notice("dmd","作品审核通过","08-04","您的作品已通过审核并展示在社区")}
  </div>
</div>
''')

# ---------------- 32 设置 ----------------
def _setrow(title, sub="", extra=""):
    return f'''<div class="row between" style="padding:14px 0;">
      <div><div class="h3" style="font-size:14px;">{title}</div>{f'<div class="ter" style="font-size:11px;margin-top:2px;">{sub}</div>' if sub else ""}</div>
      {extra}
    </div>'''

screen("32", "32-设置", f'''
{statusbar()}
{nav("设置")}
<div class="content">
  <div class="h2 mb2">账号与安全</div>
  <div class="card card-pad" style="padding:4px 16px;">
    {_setrow("手机号","138****2211 已绑定")}
    <div class="divider"></div>
    {_setrow("用户名","xiaodouzi · 已设置")}
    <div class="divider"></div>
    {_setrow("登录密码","已设置 · 可用密码登录",'<span class="cr" style="color:var(--ter);"></span>')}
    <div class="divider"></div>
    {_setrow("登录设备","2 台设备在线")}
    <div class="divider"></div>
    {_setrow("切换账号","登录其他账号",'<span class="cr" style="color:var(--ter);"></span>')}
  </div>
  <div class="h2 mt6 mb2">通用</div>
  <div class="card card-pad" style="padding:4px 16px;">
    {_setrow("消息通知","互动、系统消息提醒",'<span class="switch"></span>')}
    <div class="divider"></div>
    {_setrow("深色模式","跟随系统",'<span class="switch off"></span>')}
    <div class="divider"></div>
    {_setrow("隐私设置","谁可以评论我的作品",'<span class="cr" style="color:var(--ter);"></span>')}
  </div>
  <div class="row gap2" style="justify-content:center;padding:10px 0 2px;"><span class="ter" style="font-size:11px;">下拉查看关于与退出登录</span></div>
</div>
''')

# ---------------- 32b 设置-续 ----------------
screen("32b", "32-设置-续", f'''
{statusbar()}
{nav("设置")}
<div class="content">
  <div style="text-align:center;padding:6px 0 4px;"><span class="ter" style="font-size:10px;">· 接上一页 ·</span></div>
  <div class="h2 mb2">关于</div>
  <div class="card card-pad" style="padding:4px 16px;">
    {_setrow("版本","Think Origin v1.0.0")}
    <div class="divider"></div>
    {_setrow("用户协议","",'<span class="cr" style="color:var(--ter);"></span>')}
    <div class="divider"></div>
    {_setrow("隐私政策","",'<span class="cr" style="color:var(--ter);"></span>')}
  </div>
  <div class="btn btn-ghost btn-block mt6" style="color:var(--danger);">退出登录</div>
</div>
''')

# ---------------- 33 关注与粉丝 ----------------
def _follow_row(av, name, meta, btn):
    return f'''<div class="row gap3" style="padding:12px 0;">
      <div class="ring"><div class="inner"><div class="av {av}">{name[0]}</div></div></div>
      <div style="flex:1;min-width:0;"><div class="h3" style="font-size:14px;">{name}</div><div class="ter ellipsis">{meta}</div></div>
      {btn}
    </div>'''

screen("33", "33-关注与粉丝", f'''
{statusbar()}
{nav("小豆子")}
<div class="content">
  <div class="seg mb4"><span class="item">粉丝 1.2k</span><span class="item on">关注 86</span></div>
  <div class="card card-pad" style="padding:4px 16px;">
    {_follow_row("g2","手作阿周","拼豆教程创作者 · 上海",'<div class="btn btn-sm black">已关注</div>')}
    <div class="divider"></div>
    {_follow_row("g3","果冻","奶油胶爱好者","<div class='btn btn-sm ghost'>互相关注</div>")}
    <div class="divider"></div>
    {_follow_row("g4","柠檬精","手工萌新 · 求带","<div class='btn btn-sm black'>已关注</div>")}
    <div class="divider"></div>
    {_follow_row("g5","新手村村民","每天一个手作小技巧","<div class='btn btn-sm black'>已关注</div>")}
    <div class="divider"></div>
    {_follow_row("g6","拼豆研究所","官方号 · 分享新品","<div class='btn btn-sm outline'>关注</div>")}
  </div>
</div>
''')

# ---------------- 34 弹窗-居中确认 ----------------
screen("34", "34-弹窗-居中确认", f'''
{statusbar()}
{nav("我的订单")}
<div class="content" style="opacity:.5;">
  <div class="seg mb4"><span class="item on">全部</span><span class="item">待核销</span><span class="item">已完成</span></div>
  <div class="card card-pad mb3">
    <div class="row between mb2"><span class="h3">拾光手作馆 · 万象城店</span><span class="tag red">待核销</span></div>
    <div class="sec mb1">08-07 周五 15:00-16:30 · A1 · 2 人</div>
    <div class="ter">预约码 830219 · 微信支付 ¥49.8</div>
  </div>
  <div class="card card-pad">
    <div class="row between mb2"><span class="h3">拾光手作馆 · 大悦城店</span><span class="tag gray">已完成</span></div>
    <div class="sec mb1">07-20 周日 10:00-11:30 · B2 · 1 人</div>
    <div class="ter">已完成 · 支付宝 ¥39.9</div>
  </div>
</div>
<div class="mask"></div>
<div class="dialog">
  <div class="title">取消预约</div>
  <div class="msg">取消后该时段名额将释放，<br>优惠券会自动退回卡包，确定取消吗？</div>
  <div class="btns">
    <div class="btn btn-ghost">再想想</div>
    <div class="btn" style="background:var(--danger);">确认取消</div>
  </div>
</div>
''')

# ---------------- 35 弹窗-底部分享 ----------------
screen("35", "35-弹窗-底部分享", f'''
{statusbar()}
{nav("作品详情")}
<div class="content" style="opacity:.5;">
  <div class="photo p5" style="height:220px;border-radius:20px;"></div>
  <div class="row gap4 mt3">
    <div class="row gap1">{icon("hrt")}<span class="sec">2.3k</span></div>
    <div class="row gap1">{icon("cmt")}<span class="sec">86</span></div>
    <div class="row gap1">{icon("bmk")}<span class="sec">412</span></div>
  </div>
  <div class="mt3" style="font-size:13px;"><b>小豆子</b> 星空拼豆 2000 颗，终于完成啦～</div>
</div>
<div class="mask"></div>
<div class="sheet">
  <div class="grab"></div>
  <div class="h3" style="text-align:center;margin-bottom:18px;">分享到</div>
  <div class="row" style="justify-content:space-between;">
    <div class="cell"><div class="ico">{icon("msg")}</div><span>微信</span></div>
    <div class="cell"><div class="ico">{icon("usr")}</div><span>朋友圈</span></div>
    <div class="cell"><div class="ico">{icon("hash")}</div><span>微博</span></div>
    <div class="cell"><div class="ico">{icon("link")}</div><span>复制链接</span></div>
    <div class="cell"><div class="ico">{icon("dl")}</div><span>保存图片</span></div>
    <div class="cell"><div class="ico">{icon("dots")}</div><span>更多</span></div>
  </div>
  <div class="divider" style="margin:20px 0 6px;"></div>
  <div class="row between" style="padding:12px 4px;">
    <div class="row gap3">{icon("dmd","ic-sm")}<span style="font-size:14px;">举报作品</span></div>
    <span class="ter" style="font-size:12px;">内容违规或侵权</span>
  </div>
  <div class="btn btn-ghost btn-block" style="height:48px;border-radius:16px;margin-top:4px;">取消</div>
</div>
''')

# ---------------- 36 聊天-长按气泡菜单 ----------------
screen("36", "36-聊天-长按气泡菜单", f'''
{statusbar()}
{nav("小豆子", right_html='<span class="badge-dot" style="background:var(--ok);"></span>')}
<div class="toast">长按消息气泡可呼出操作菜单</div>
<div style="position:absolute;left:0;right:0;top:106px;bottom:74px;padding:20px 16px;display:flex;flex-direction:column;gap:16px;">
  <div class="row gap2" style="align-items:flex-start;">
    <div class="av sm g1">豆</div>
    <div style="max-width:250px;background:var(--surface);border-radius:16px 16px 16px 4px;padding:10px 14px;font-size:14px;">今晚要一起拼豆吗？我买了新的星空材料包</div>
  </div>
  <div style="display:flex;justify-content:flex-end;">
    <div class="bubble-hl" style="max-width:250px;background:var(--ink);color:#fff;border-radius:16px 16px 4px 16px;padding:10px 14px;font-size:14px;">好啊！几点？在万象城店吗</div>
  </div>
  <div class="row gap2" style="align-items:flex-start;">
    <div class="av sm g1">豆</div>
    <div style="max-width:250px;background:var(--surface);border-radius:16px 16px 16px 4px;padding:10px 14px;font-size:14px;">19:30 不见不散，记得带上卡包里的会员券～</div>
  </div>
</div>
<div class="chatmenu wx" style="right:16px;bottom:150px;">
  <div class="mi on">复制</div>
  <div class="mi">转发</div>
  <div class="mi">收藏</div>
  <div class="mi">撤回</div>
  <div class="mi">删除</div>
  <div class="mi">多选</div>
</div>
{chat_input()}
''')

# ---------------- 37 动效与交互规范 ----------------
def _motion(icon_cls, title, desc, tags):
    return f'''<div class="motion-row">
      <div class="num">{icon(icon_cls,"ic-sm")}</div>
      <div class="info"><div class="t">{title}</div><div class="d">{desc}</div></div>
      <div class="row gap1">{"".join(f'<span class="motion-tag {("b" if i==0 else "")}">{t}</span>' for i,t in enumerate(tags))}</div>
    </div>'''

screen("37", "37-动效与交互规范", f'''
{statusbar()}
{nav("动效与交互规范")}
<div class="content">
  <div class="h2 mb2">页面转场</div>
  <div class="card card-pad" style="padding:2px 16px;">
    {_motion("cr","页面推入 / 返回","二级页从右推入，返回向左滑出",("300ms","标准"))}
    <div class="divider"></div>
    {_motion("reel","Reels 全屏翻页","上下滑动切换，视频淡入",("400ms","弹性"))}
    <div class="divider"></div>
    {_motion("tab","Tab 切换","图标微缩放 + 胶囊背景过渡",("200ms","标准"))}
  </div>
  <div class="h2 mt6 mb2">弹窗与菜单</div>
  <div class="card card-pad" style="padding:2px 16px;">
    {_motion("dmd","居中弹窗","缩放 0.92→1 + 淡入，背景压暗",("200ms","强调"))}
    <div class="divider"></div>
    {_motion("menu","底部弹窗 / 分享面板","从底部平移滑入 + 轻微回弹",("280ms","弹性"))}
    <div class="divider"></div>
    {_motion("cmt","长按气泡菜单","在气泡旁弹出，缩放淡入",("150ms","标准"))}
    <div class="divider"></div>
    {_motion("lst","右侧抽屉菜单","从右滑入，遮罩渐变压暗",("260ms","标准"))}
  </div>
  <div class="row gap2" style="justify-content:center;padding:10px 0 2px;"><span class="ter" style="font-size:11px;">下拉查看微交互与动效曲线</span></div>
</div>
''')

# ---------------- 37b 动效与交互规范-续 ----------------
screen("37b", "37-动效与交互规范-续", f'''
{statusbar()}
{nav("动效与交互规范")}
<div class="content">
  <div style="text-align:center;padding:6px 0 4px;"><span class="ter" style="font-size:10px;">· 接上一页 ·</span></div>
  <div class="h2 mb2">微交互</div>
  <div class="card card-pad" style="padding:2px 16px;">
    {_motion("hrt","点赞 / 收藏","心跳缩放 1→1.3→1 + 计数 +1",("350ms","弹性"))}
    <div class="divider"></div>
    {_motion("cam","拍摄快门","白色圆环收缩反馈 + 闪光",("150ms","标准"))}
    <div class="divider"></div>
    {_motion("clk","计时数字滚动","上钟/下钟时长数字滚动",("100ms","滚动"))}
    <div class="divider"></div>
    {_motion("msg","新消息气泡","淡入 + 轻微上移，未读角标弹出",("220ms","标准"))}
    <div class="divider"></div>
    {_motion("reel","播放进度条","已播进度平滑前进 + 拖动手柄",("250ms","线性"))}
  </div>
  <div class="card-flat card-pad mt4" style="background:#F6F6F8;">
    <div class="ter" style="font-size:12px;line-height:1.7;">动效曲线：标准 cubic-bezier(0.2,0,0,1) · 弹性 cubic-bezier(0.34,1.56,0.64,1) · 线性 linear</div>
  </div>
</div>
''')

# ---------------- 38 弹窗-删除作品确认 ----------------
screen("38", "38-弹窗-删除作品确认", f'''
{statusbar()}
{nav("作品详情")}
<div class="content" style="opacity:.5;">
  <div class="photo p5" style="height:230px;border-radius:20px;"></div>
  <div class="row gap4 mt3">
    <div class="row gap1">{icon("hrt")}<span class="sec">2.3k</span></div>
    <div class="row gap1">{icon("cmt")}<span class="sec">86</span></div>
    <div class="row gap1">{icon("bmk")}<span class="sec">412</span></div>
  </div>
  <div class="mt3" style="font-size:13px;"><b>小豆子</b> 星空拼豆 2000 颗，终于完成啦～</div>
</div>
<div class="mask"></div>
<div class="dialog">
  <div class="title">删除作品</div>
  <div class="msg">删除后不可恢复，作品下的评论和点赞也会一并删除，确定删除吗？</div>
  <div class="btns">
    <div class="btn btn-ghost">取消</div>
    <div class="btn" style="background:var(--danger);">删除</div>
  </div>
</div>
''')

# ---------------- 39 弹窗-退出登录确认 ----------------
screen("39", "39-弹窗-退出登录确认", f'''
{statusbar()}
{nav("设置")}
<div class="content" style="opacity:.5;">
  <div class="h2 mb2">账号与安全</div>
  <div class="card card-pad" style="padding:4px 16px;">
    <div class="row between" style="padding:14px 0;"><div><div class="h3" style="font-size:14px;">手机号</div><div class="ter" style="font-size:11px;margin-top:2px;">138****2211 已绑定</div></div></div>
    <div class="divider"></div>
    <div class="row between" style="padding:14px 0;"><div><div class="h3" style="font-size:14px;">登录密码</div><div class="ter" style="font-size:11px;margin-top:2px;">已设置 · 可用密码登录</div></div></div>
    <div class="divider"></div>
    <div class="row between" style="padding:14px 0;"><div><div class="h3" style="font-size:14px;">登录设备</div><div class="ter" style="font-size:11px;margin-top:2px;">2 台设备在线</div></div></div>
  </div>
</div>
<div class="mask"></div>
<div class="dialog">
  <div class="title">退出登录</div>
  <div class="msg">退出后需要重新登录，才能查看消息、预约和会员信息，确定退出吗？</div>
  <div class="btns">
    <div class="btn btn-ghost">取消</div>
    <div class="btn" style="background:var(--danger);">退出登录</div>
  </div>
</div>
''')

# ---------------- 40 弹窗-群聊踢人确认 ----------------
screen("40", "40-弹窗-群聊踢人确认", f'''
{statusbar()}
{nav("群聊设置")}
<div class="content" style="opacity:.5;">
  <div class="h2 mb2">群成员 12</div>
  <div class="card card-pad" style="padding:4px 16px;">
    <div class="row gap3" style="padding:12px 0;">
      <div class="av g3">果</div>
      <div style="flex:1;"><div class="h3" style="font-size:14px;">果冻</div><div class="ter">加入于 07-28</div></div>
      <span class="tag gray">成员</span>
    </div>
    <div class="divider"></div>
    <div class="row gap3" style="padding:12px 0;">
      <div class="av g4">柠</div>
      <div style="flex:1;"><div class="h3" style="font-size:14px;">柠檬精</div><div class="ter">加入于 07-25</div></div>
      <span class="tag gray">成员</span>
    </div>
  </div>
</div>
<div class="mask"></div>
<div class="dialog">
  <div style="display:flex;justify-content:center;margin-bottom:12px;"><div class="av g3">果</div></div>
  <div class="title">将「果冻」移出群聊</div>
  <div class="msg">移出后 TA 将无法查看群聊消息，其他成员仍可重新邀请</div>
  <div class="btns">
    <div class="btn btn-ghost">取消</div>
    <div class="btn" style="background:var(--danger);">移出</div>
  </div>
</div>
''')

# ---------------- 41 弹窗-照片选择 ----------------
def _pick_cell(photo="", selected=False, camera=False):
    if camera:
        return '<div style="height:104px;border-radius:12px;background:var(--surface);display:flex;flex-direction:column;align-items:center;justify-content:center;gap:5px;color:var(--sec);">{icon("cam","ic-sm")}<span style="font-size:10px;">拍摄</span></div>'
    mark = f'<span style="position:absolute;right:6px;top:6px;width:20px;height:20px;border-radius:50%;background:var(--ink);display:flex;align-items:center;justify-content:center;color:#fff;">{icon("tick","ic-sm")}</span>' if selected else ""
    return f'<div class="photo {photo}" style="height:104px;border-radius:12px;position:relative;">{mark}</div>'

screen("41", "41-弹窗-照片选择", f'''
{statusbar()}
<div class="nav">
  <div class="back" style="width:56px;font-size:14px;color:var(--sec);padding-left:12px;">取消</div>
  <div class="title" style="font-size:16px;">发微博</div>
  <div class="btn btn-sm black" style="position:absolute;right:12px;height:32px;border-radius:16px;font-size:13px;">发布</div>
</div>
<div class="content" style="opacity:.5;">
  <div class="textarea mb3" style="min-height:70px;background:transparent;padding:8px 0;"><span class="ph">分享新鲜事…</span></div>
  <div class="grid3" style="grid-template-columns:repeat(3,1fr);gap:4px;">
    <div style="height:104px;border-radius:12px;background:var(--surface);display:flex;flex-direction:column;align-items:center;justify-content:center;gap:5px;color:var(--sec);">{icon("cam","ic-sm")}<span style="font-size:10px;">拍摄 / 相册</span></div>
    <div class="photo p2" style="height:104px;border-radius:12px;"></div>
    <div class="photo p6" style="height:104px;border-radius:12px;"></div>
  </div>
</div>
<div class="mask"></div>
<div class="sheet" style="padding-bottom:0;">
  <div class="grab"></div>
  <div class="row between" style="padding:0 4px 14px;">
    <span class="h3">从相册选择</span><span class="ter">已选 5 / 9</span>
  </div>
  <div class="grid3" style="gap:4px;padding-bottom:16px;">
    {_pick_cell(camera=True)}
    {_pick_cell("p2", True)}
    {_pick_cell("p6", True)}
    {_pick_cell("p3", True)}
    {_pick_cell("p5", True)}
    {_pick_cell("p1")}
    {_pick_cell("p9")}
    {_pick_cell("p7")}
    {_pick_cell("p11")}
  </div>
  <div style="border-top:1px solid var(--line);padding:12px 0 24px;display:flex;align-items:center;gap:10px;">
    <div style="flex:1;display:flex;gap:5px;">
      <div class="photo p2" style="width:34px;height:34px;border-radius:8px;"></div>
      <div class="photo p6" style="width:34px;height:34px;border-radius:8px;"></div>
      <div class="photo p3" style="width:34px;height:34px;border-radius:8px;"></div>
      <div class="photo p5" style="width:34px;height:34px;border-radius:8px;"></div>
      <div class="photo p1" style="width:34px;height:34px;border-radius:8px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:11px;">+1</div>
    </div>
    <div class="btn btn-ghost" style="height:44px;padding:0 18px;font-size:14px;">预览</div>
    <div class="btn btn-black" style="height:44px;padding:0 18px;font-size:14px;">完成 (5)</div>
  </div>
</div>
''')

# ---------------- 42 会话-长按菜单 ----------------
screen("42", "42-会话-长按菜单", f'''
{statusbar()}
<div class="nav">
  <div class="title" style="font-size:20px;font-weight:800;">聊天</div>
  <div class="right">{icon("pl","ic-sm")}</div>
</div>
<div class="toast">长按会话可置顶 / 标记未读</div>
<div class="content" style="opacity:.6;">
  <div class="field mb4">{icon("srch","ic-sm")}<span class="ph">搜索</span></div>
  <div class="card-flat card-pad" style="padding:4px 16px;">
    {_conv("g1","小豆子","[图片] 看我新做的星空拼豆！","14:20","2",True)}
    <div class="divider"></div>
    {_conv("g2","手作同好会","阿周: 今晚 8 点拼豆直播，来呀","13:05","",True,True)}
    <div class="divider"></div>
    {_conv("g3","果冻","语音 12″","12:40","5")}
  </div>
</div>
<div class="chatmenu" style="left:34px;top:252px;">
  <div class="mi on">{icon("pin","ic-sm")}<span>置顶聊天</span></div>
  <div class="mi">{icon("udot","ic-sm")}<span>标为未读</span></div>
  <div class="mi" style="color:var(--danger);">{icon("trash","ic-sm")}<span>删除会话</span></div>
</div>
{tabbar("msg")}
''')

# ---------------- 43 观看历史 ----------------
def _hist_row(photo, title, meta, time):
    return f'''<div class="row gap3" style="padding:12px 0;">
      <div class="photo {photo}" style="width:52px;height:52px;border-radius:12px;flex:none;"></div>
      <div style="flex:1;min-width:0;"><div class="h3" style="font-size:14px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">{title}</div>
        <div class="ter" style="margin-top:2px;">{meta}</div></div>
      <div style="text-align:right;"><div class="ter" style="font-size:11px;">{time}</div><div style="margin-top:6px;">{icon("x","ic-sm")}</div></div>
    </div>'''

screen("43", "43-观看历史", f'''
{statusbar()}
{nav("观看历史", right_html='<span class="sec" style="font-size:13px;">清空</span>')}
<div class="content">
  <div class="seg mb4"><span class="item on">作品</span><span class="item">视频</span></div>
  <div class="card card-pad" style="padding:4px 16px;">
    {_hist_row("p5","星空拼豆 2000 颗","小豆子 · 作品","08-06 14:32")}
    <div class="divider"></div>
    {_hist_row("p2","渐变拼豆新手教程","手作阿周 · 视频","08-06 13:10")}
    <div class="divider"></div>
    {_hist_row("p6","奶油胶手机壳 DIY","果冻 · 作品","08-05 20:41")}
    <div class="divider"></div>
    {_hist_row("p9","亲子手作工坊实录","Think Origin · 视频","08-05 16:22")}
    <div class="divider"></div>
    {_hist_row("p3","七夕主题拼豆作品合集","柠檬精 · 作品","08-04 11:05")}
  </div>
  <div class="btn btn-ghost btn-block mt4" style="color:var(--danger);">清空观看历史</div>
</div>
''')

# ---------------- 44 预约详情 ----------------
screen("44", "44-预约详情", f'''
{statusbar()}
{nav("预约详情")}
<div class="content">
  <div class="card card-pad mb4">
    <div class="row between mb2"><span class="h3">拾光手作馆 · 万象城店</span><span class="tag red">待核销</span></div>
    <div class="sec mb1">08-07 周五 15:00-16:30 · A1 · 2 人</div>
    <div class="divider" style="margin:12px 0;"></div>
    <div class="row between mb2"><span class="sec">预约码</span><span style="font-size:20px;font-weight:700;letter-spacing:3px;">830219</span></div>
    <div class="row gap2"><div class="btn btn-black btn-sm" style="flex:1;height:40px;">复制</div><div class="btn btn-ghost btn-sm" style="flex:1;height:40px;">扫码核销</div></div>
  </div>
  <div class="h2 mb2">预约进度</div>
  <div class="card card-pad">
    <div class="row">
      <div class="row" style="flex-direction:column;align-items:center;gap:5px;flex:1;"><div style="width:26px;height:26px;border-radius:50%;background:var(--ink);color:#fff;display:flex;align-items:center;justify-content:center;">{icon("tick","ic-sm")}</div><span style="font-size:10px;">已支付</span></div>
      <div style="flex:1;height:2px;background:var(--ink);"></div>
      <div class="row" style="flex-direction:column;align-items:center;gap:5px;flex:1;"><div style="width:26px;height:26px;border-radius:50%;background:var(--ink);color:#fff;display:flex;align-items:center;justify-content:center;">{icon("tick","ic-sm")}</div><span style="font-size:10px;">待核销</span></div>
      <div style="flex:1;height:2px;background:var(--line);"></div>
      <div class="row" style="flex-direction:column;align-items:center;gap:5px;flex:1;"><div style="width:26px;height:26px;border-radius:50%;background:var(--surface);color:var(--ter);display:flex;align-items:center;justify-content:center;">{icon("clk","ic-sm")}</div><span style="font-size:10px;color:var(--ter);">体验中</span></div>
      <div style="flex:1;height:2px;background:var(--line);"></div>
      <div class="row" style="flex-direction:column;align-items:center;gap:5px;flex:1;"><div style="width:26px;height:26px;border-radius:50%;background:var(--surface);color:var(--ter);display:flex;align-items:center;justify-content:center;">{icon("fire","ic-sm")}</div><span style="font-size:10px;color:var(--ter);">完成</span></div>
    </div>
  </div>
  <div class="h2 mt6 mb2">订单信息</div>
  <div class="card card-pad">
    <div class="row between mb2"><span class="sec">预约类型</span><span class="h3" style="font-size:14px;">门店桌位</span></div>
    <div class="row between mb2"><span class="sec">预约单号</span><span class="h3" style="font-size:14px;">AP202608070015</span></div>
    <div class="row between mb2"><span class="sec">创建时间</span><span class="h3" style="font-size:14px;">08-06 20:12</span></div>
    <div class="row between mb2"><span class="sec">支付方式</span><span class="h3" style="font-size:14px;">微信支付</span></div>
    <div class="divider" style="margin:10px 0;"></div>
    <div class="row between"><span class="sec">实付金额</span><span class="price">¥49.8</span></div>
  </div>
</div>
<div style="position:absolute;left:16px;right:16px;bottom:20px;display:flex;gap:12px;">
  <div class="btn btn-ghost" style="flex:1;height:50px;border-radius:16px;color:var(--danger);">取消预约</div>
  <div class="btn btn-black" style="flex:1;height:50px;border-radius:16px;">去核销</div>
</div>
''')

# ---------------- 45 输入核销码 ----------------
screen("45", "45-输入核销码", f'''
{statusbar()}
{nav("到店核销")}
<div class="content">
  <div style="text-align:center;padding:28px 0 20px;">
    <div style="width:72px;height:72px;border-radius:50%;background:var(--surface);display:flex;align-items:center;justify-content:center;margin:0 auto 16px;">{icon("qrc","ic-lg")}</div>
    <div class="h2">输入预约码</div>
    <div class="sec mt2">输入店员提供的 6 位预约码进行核销</div>
  </div>
  <div class="row gap2" style="justify-content:center;margin-bottom:28px;">
    <div style="width:46px;height:58px;border-radius:12px;border:1.5px solid var(--ink);display:flex;align-items:center;justify-content:center;font-size:26px;font-weight:700;">8</div>
    <div style="width:46px;height:58px;border-radius:12px;border:1.5px solid var(--ink);display:flex;align-items:center;justify-content:center;font-size:26px;font-weight:700;">3</div>
    <div style="width:46px;height:58px;border-radius:12px;border:1.5px solid var(--ink);display:flex;align-items:center;justify-content:center;font-size:26px;font-weight:700;">0</div>
    <div style="width:46px;height:58px;border-radius:12px;border:1.5px solid var(--ink);display:flex;align-items:center;justify-content:center;font-size:26px;font-weight:700;">2</div>
    <div style="width:46px;height:58px;border-radius:12px;border:1.5px solid var(--ink);display:flex;align-items:center;justify-content:center;font-size:26px;font-weight:700;">1</div>
    <div style="width:46px;height:58px;border-radius:12px;border:1.5px solid var(--line);display:flex;align-items:center;justify-content:center;"><div style="width:2px;height:22px;background:var(--ink);"></div></div>
  </div>
  <div class="btn btn-ghost btn-block mb3">查询预约</div>
  <div class="btn btn-black btn-block">确认核销</div>
  <div class="row gap2 mt4" style="justify-content:center;"><span class="ter" style="font-size:12px;">也可以</span><span class="sec" style="font-size:12px;font-weight:600;">扫码核销</span></div>
</div>
''')

# ---------------- 46 预约成功 ----------------
screen("46", "46-预约成功", f'''
{statusbar()}
<div class="content" style="text-align:center;padding-top:60px;">
  <div style="width:92px;height:92px;border-radius:50%;background:var(--ink);color:#fff;display:flex;align-items:center;justify-content:center;margin:0 auto 22px;">{icon("tick","ic-lg")}</div>
  <div class="h1" style="font-size:24px;">预约成功</div>
  <div class="sec mt2">请按时到店，出示预约码核销开始体验</div>
  <div class="card card-pad mt6" style="text-align:left;">
    <div class="row between mb2"><span class="sec">门店</span><span class="h3" style="font-size:14px;">拾光手作馆 · 万象城店</span></div>
    <div class="row between mb2"><span class="sec">时间</span><span class="h3" style="font-size:14px;">08-07 周五 15:00-16:30</span></div>
    <div class="row between mb2"><span class="sec">桌位 / 人数</span><span class="h3" style="font-size:14px;">A1 · 2 人</span></div>
    <div class="row between mb2"><span class="sec">实付</span><span class="price" style="font-size:15px;">¥49.8</span></div>
    <div class="divider" style="margin:12px 0;"></div>
    <div style="text-align:center;background:var(--surface);border-radius:14px;padding:14px;">
      <div class="ter" style="font-size:11px;">预约码（到店出示）</div>
      <div style="font-size:26px;font-weight:700;letter-spacing:4px;margin-top:6px;">830219</div>
    </div>
  </div>
  <div class="btn btn-black btn-block mt6">查看预约</div>
  <div class="btn btn-ghost btn-block mt3">返回首页</div>
</div>
''')

# ---------------- 47 会员开通确认 ----------------
screen("47", "47-会员开通确认", f'''
{statusbar()}
{nav("会员开通")}
<div class="content">
  <div class="card card-pad mb4" style="border-color:transparent;background:var(--ink);color:#fff;">
    <div class="row between mb2"><span style="opacity:.75;font-size:13px;">手作会员 · 年卡</span><span style="font-size:12px;font-weight:600;">365 天</span></div>
    <div class="row gap2" style="align-items:flex-end;"><span style="font-size:30px;font-weight:700;">¥299</span><span style="font-size:14px;text-decoration:line-through;opacity:.6;margin-bottom:4px;">¥399</span></div>
    <div class="row gap2 mt3" style="flex-wrap:wrap;">
      <span style="font-size:11px;background:rgba(255,255,255,.16);border-radius:9px;padding:3px 8px;">会员专属价</span>
      <span style="font-size:11px;background:rgba(255,255,255,.16);border-radius:9px;padding:3px 8px;">专属活动</span>
      <span style="font-size:11px;background:rgba(255,255,255,.16);border-radius:9px;padding:3px 8px;">每月优惠券</span>
    </div>
  </div>
  <div class="card-flat card-pad mb4">
    <div class="row between mb2"><span class="sec">套餐原价</span><span class="sec">¥399</span></div>
    <div class="row between mb2"><span class="sec">限时优惠</span><span class="sec" style="color:var(--ok);">-¥100</span></div>
    <div class="divider" style="margin:8px 0;"></div>
    <div class="row between"><span class="h3">实付金额</span><span class="price" style="font-size:20px;">¥299</span></div>
  </div>
  <div class="h2 mb2">支付方式</div>
  <div class="card card-pad">
    <div class="row between mb3"><div class="row gap3"><span class="iconbox" style="width:34px;height:34px;border-radius:10px;background:var(--ink);color:#fff;">{icon("msg","ic-sm")}</span><span class="h3">微信支付</span></div><span class="radio on"></span></div>
    <div class="divider"></div>
    <div class="row between mt3"><div class="row gap3"><span class="iconbox" style="width:34px;height:34px;border-radius:10px;">{icon("wal","ic-sm")}</span><span class="h3">支付宝</span></div><span class="radio"></span></div>
  </div>
  <div class="ter" style="text-align:center;margin-top:16px;font-size:11px;">支付即代表同意《会员服务协议》，开通后立即生效</div>
</div>
<div style="position:absolute;left:16px;right:16px;bottom:20px;"><div class="btn btn-black btn-block">确认支付 ¥299</div></div>
''')

# ---------------- 48 领券中心 ----------------
def _coupon_center(amount, title, meta, state):
    if state == "get":
        btn = '<div class="btn btn-sm black" style="height:30px;font-size:12px;">立即领取</div>'
    elif state == "got":
        btn = '<div class="btn btn-sm ghost" style="height:30px;font-size:12px;">已领取</div>'
    else:
        btn = '<div class="btn btn-sm ghost" style="height:30px;font-size:12px;opacity:.5;">已领完</div>'
    return f'''<div class="row mb3" style="height:84px;border-radius:16px;border:1px solid var(--line);overflow:hidden;">
      <div style="width:92px;background:var(--ink);color:#fff;display:flex;flex-direction:column;align-items:center;justify-content:center;position:relative;">
        <div style="font-size:26px;font-weight:700;">{amount}</div><div style="font-size:11px;">优惠券</div>
        <div style="position:absolute;right:-6px;top:-6px;width:12px;height:12px;border-radius:50%;background:#fff;"></div>
        <div style="position:absolute;right:-6px;bottom:-6px;width:12px;height:12px;border-radius:50%;background:#fff;"></div>
      </div>
      <div style="flex:1;padding:12px 14px;">
        <div style="font-size:14px;font-weight:600;">{title}</div>
        <div class="ter" style="font-size:11px;margin-top:3px;">{meta}</div>
      </div>
      <div style="display:flex;align-items:center;padding-right:14px;">{btn}</div>
    </div>'''

screen("48", "48-领券中心", f'''
{statusbar()}
{nav("领券中心")}
<div class="content">
  <div class="sec mb3">会员每月可额外领取专属券</div>
  {_coupon_center("¥10","新人立减券","满 39 元可用 · 08-31 到期","get")}
  {_coupon_center("¥20","会员专属券","满 79 元可用 · 会员专享","get")}
  {_coupon_center("¥30","手作嘉年华券","满 129 元可用 · 限 8 月","get")}
  {_coupon_center("¥50","周年庆大额券","满 199 元可用 · 09-01 到期","got")}
  {_coupon_center("¥15","门店通用券","满 59 元可用","out")}
</div>
''')

# ---------------- 49 社区搜索 ----------------
screen("49", "49-社区搜索", f'''
{statusbar()}
<div class="nav">
  <div class="back">{icon("bk")}</div>
  <div class="field" style="position:absolute;left:48px;right:64px;top:4px;height:36px;border-radius:18px;">{icon("srch","ic-sm")}<span style="font-size:13px;color:var(--ink);">拼豆</span></div>
  <div class="right" style="font-size:14px;">搜索</div>
</div>
<div class="content">
  <div class="seg mb4"><span class="item on">综合</span><span class="item">用户</span><span class="item">话题</span></div>
  <div class="card card-pad mb3">
    <div class="row gap3">
      <div class="av g2">周</div>
      <div style="flex:1;"><div class="h3" style="font-size:14px;">手作阿周</div><div class="ter">拼豆教程创作者 · 12.5w 粉丝</div></div>
      <div class="btn btn-sm black">关注</div>
    </div>
  </div>
  <div class="card card-pad mb3">
    <div class="row gap2 mb3"><div class="av sm g1">豆</div><div><div class="h3" style="font-size:13px;">小豆子</div><div class="ter" style="font-size:11px;">08-06 · 作品</div></div></div>
    <div class="photo p5" style="height:150px;border-radius:12px;"></div>
    <div class="mt2" style="font-size:13px;"><b>小豆子</b> 用 <b style="color:var(--ink);">拼豆</b> 做的星空图，绝美！</div>
    <div class="row between mt2"><div class="row gap4">{icon("hrt","ic-sm")}<span style="font-size:12px;">2.3k</span>{icon("cmt","ic-sm")}<span style="font-size:12px;">86</span></div>{icon("bmk","ic-sm")}</div>
  </div>
  <div class="row gap2" style="justify-content:center;padding:6px 0 2px;"><span class="ter" style="font-size:11px;">下拉查看更多搜索结果</span></div>
</div>
''')

# ---------------- 49b 社区搜索-续 ----------------
screen("49b", "49-社区搜索-续", f'''
{statusbar()}
<div class="nav">
  <div class="back">{icon("bk")}</div>
  <div class="field" style="position:absolute;left:48px;right:64px;top:4px;height:36px;border-radius:18px;">{icon("srch","ic-sm")}<span style="font-size:13px;color:var(--ink);">拼豆</span></div>
  <div class="right" style="font-size:14px;">搜索</div>
</div>
<div class="content">
  <div style="text-align:center;padding:6px 0 4px;"><span class="ter" style="font-size:10px;">· 接上一页 ·</span></div>
  <div class="seg mb4"><span class="item on">综合</span><span class="item">用户</span><span class="item">话题</span></div>
  <div class="card card-pad mb3">
    <div class="row gap3">
      <div class="iconbox soft">{icon("hash","ic-sm")}</div>
      <div style="flex:1;"><div class="h3" style="font-size:14px;">#拼豆星球</div><div class="ter">3.2k 帖子 · 1.8w 关注</div></div>
      <div class="btn btn-sm outline">进话题</div>
    </div>
  </div>
  <div class="card card-pad">
    <div class="row gap2 mb3"><div class="av sm g6">果</div><div><div class="h3" style="font-size:13px;">果冻</div><div class="ter" style="font-size:11px;">08-05 · 作品</div></div></div>
    <div class="photo p6" style="height:150px;border-radius:12px;"></div>
    <div class="mt2" style="font-size:13px;">奶油胶手机壳，<b style="color:var(--ink);">拼豆</b> 点缀太可爱了</div>
    <div class="row between mt2"><div class="row gap4">{icon("hrt","ic-sm")}<span style="font-size:12px;">860</span>{icon("cmt","ic-sm")}<span style="font-size:12px;">42</span></div>{icon("bmk","ic-sm")}</div>
  </div>
</div>
''')

# ---------------- 69 搜索首页 ----------------
screen("69", "69-搜索首页", f'''
{statusbar()}
<div class="nav">
  <div class="back">{icon("bk")}</div>
  <div class="field" style="position:absolute;left:48px;right:64px;top:4px;height:36px;border-radius:18px;outline:1.5px solid var(--ink);">{icon("srch","ic-sm")}<span style="font-size:13px;color:var(--ink);">搜索作品 / 视频 / 用户 / 话题</span></div>
  <div class="right" style="font-size:14px;">搜索</div>
</div>
<div class="content">
  <div class="row gap2 mt2">
    <div class="chip on" style="height:28px;font-size:12px;">作品</div><div class="chip" style="height:28px;font-size:12px;">视频</div><div class="chip" style="height:28px;font-size:12px;">用户</div><div class="chip" style="height:28px;font-size:12px;">话题</div>
  </div>
  <div class="section-title"><span class="h2">搜索历史</span><span class="more">清空</span></div>
  <div class="row gap2" style="flex-wrap:wrap;">
    <div class="chip" style="height:30px;">拼豆</div><div class="chip" style="height:30px;">星空图</div><div class="chip" style="height:30px;">手作阿周</div><div class="chip" style="height:30px;">奶油胶</div>
  </div>
  <div class="section-title"><span class="h2">热门搜索</span><span class="more">换一批</span></div>
  <div class="card card-pad" style="padding:4px 16px;">
    <div class="row gap3" style="padding:11px 0;"><span style="width:22px;font-size:14px;font-weight:700;color:var(--danger);">1</span><span class="h3" style="font-size:14px;">拼豆教程</span><span style="flex:1;"></span><span class="tag red" style="height:16px;font-size:9px;">热</span></div>
    <div class="divider"></div>
    <div class="row gap3" style="padding:11px 0;"><span style="width:22px;font-size:14px;font-weight:700;color:var(--danger);">2</span><span class="h3" style="font-size:14px;">星空拼豆</span><span style="flex:1;"></span><span class="ter" style="font-size:11px;">12.5w 搜索</span></div>
    <div class="divider"></div>
    <div class="row gap3" style="padding:11px 0;"><span style="width:22px;font-size:14px;font-weight:700;color:var(--warn);">3</span><span class="h3" style="font-size:14px;">奶油胶手机壳</span><span style="flex:1;"></span><span class="ter" style="font-size:11px;">9.8w 搜索</span></div>
    <div class="divider"></div>
    <div class="row gap3" style="padding:11px 0;"><span style="width:22px;font-size:14px;font-weight:700;">4</span><span class="h3" style="font-size:14px;">七夕拼豆派对</span><span style="flex:1;"></span><span class="ter" style="font-size:11px;">6.2w 搜索</span></div>
    <div class="divider"></div>
    <div class="row gap3" style="padding:11px 0;"><span style="width:22px;font-size:14px;font-weight:700;">5</span><span class="h3" style="font-size:14px;">Think Origin</span><span style="flex:1;"></span><span class="ter" style="font-size:11px;">5.1w 搜索</span></div>
  </div>
</div>
''')

# ---------------- 70 视频搜索 ----------------
def _video_result(photo, title, author, meta, dur):
    return f'''<div class="row gap3 mb3">
      <div class="photo {photo}" style="width:132px;height:84px;border-radius:12px;flex:none;position:relative;">
        <div style="position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);width:30px;height:30px;border-radius:50%;background:rgba(255,255,255,.9);display:flex;align-items:center;justify-content:center;color:#141414;">{icon("py","ic-sm")}</div>
        <span style="position:absolute;right:6px;bottom:5px;background:rgba(0,0,0,.6);color:#fff;border-radius:5px;padding:1px 6px;font-size:9px;" class="num">{dur}</span>
      </div>
      <div style="flex:1;min-width:0;">
        <div style="font-size:14px;font-weight:600;line-height:1.4;">{title}</div>
        <div class="ter" style="font-size:11px;margin-top:3px;">{author}</div>
        <div class="ter" style="font-size:11px;margin-top:2px;">{meta}</div>
      </div>
    </div>'''

screen("70", "70-视频搜索", f'''
{statusbar()}
<div class="nav">
  <div class="back">{icon("bk")}</div>
  <div class="field" style="position:absolute;left:48px;right:64px;top:4px;height:36px;border-radius:18px;outline:1.5px solid var(--ink);">{icon("srch","ic-sm")}<span style="font-size:13px;color:var(--ink);">拼豆</span></div>
  <div class="right" style="font-size:14px;">搜索</div>
</div>
<div class="content">
  <div class="row gap2 mt2 mb4"><span class="chip on" style="height:28px;font-size:12px;">综合</span><span class="chip" style="height:28px;font-size:12px;">最新</span><span class="chip" style="height:28px;font-size:12px;">最热</span></div>
  {_video_result("p10","3 分钟学会渐变拼豆，新手也能轻松上手","手作阿周 · 12.5w 粉丝","1.2w 赞 · 昨天", "01:30")}
  <div class="divider mb3"></div>
  {_video_result("p2","星空拼豆 2000 颗完整过程，治愈到不行","小豆子 · 手作博主","3.6w 赞 · 前天", "02:15")}
  <div class="divider mb3"></div>
  {_video_result("p8","拼豆熨烫技巧实测：温度和时间对照表","拼豆研究所 · 官方号","9.8k 赞 · 3 天前", "00:58")}
  <div class="divider mb3"></div>
  {_video_result("p6","奶油胶拼豆手机壳 DIY，配色教程","果冻 · 手工达人","6.2k 赞 · 4 天前", "01:12")}
  <div class="row gap2" style="justify-content:center;padding:10px 0;"><span class="ter" style="font-size:11px;">共 326 条结果 · 下拉查看更多</span></div>
</div>
''')

# ---------------- 50 话题频道页 ----------------
screen("50", "50-话题频道页", f'''
{statusbar()}
{nav("话题详情", right_icon=icon("dots"))}
<div class="photo p8" style="height:150px;border-radius:0 0 24px 24px;">
  <div style="position:absolute;inset:0;background:linear-gradient(180deg,rgba(0,0,0,.1),rgba(0,0,0,.55));"></div>
  <div style="position:absolute;left:16px;bottom:14px;color:#fff;">
    <div style="font-size:20px;font-weight:700;"># 芙宁娜的后花园</div>
    <div style="font-size:12px;opacity:.85;margin-top:4px;">3.2k 帖子 · 1.8w 关注</div>
  </div>
</div>
<div class="content">
  <div class="row gap3" style="margin-top:12px;">
    <div class="btn btn-black btn-sm" style="flex:1;height:40px;border-radius:14px;">关注话题</div>
    <div class="btn btn-ghost btn-sm" style="flex:1;height:40px;border-radius:14px;">参与发布</div>
  </div>
  <div class="row gap2 mt4"><span class="chip on" style="height:28px;font-size:12px;">最新</span><span class="chip" style="height:28px;font-size:12px;">热门</span><span style="flex:1;"></span><span class="ter" style="font-size:12px;">共 3.2k</span></div>
  <div class="grid3" style="margin-top:12px;">
    <div class="photo p5 cell"><div class="ov">{icon("hrt","ic-sm")} 2.3k</div></div>
    <div class="photo p1 cell"><div class="ov">{icon("hrt","ic-sm")} 1.1k</div></div>
    <div class="photo p3 cell"><div class="ov">{icon("hrt","ic-sm")} 860</div></div>
    <div class="photo p9 cell"><div class="ov">{icon("hrt","ic-sm")} 620</div></div>
    <div class="photo p7 cell"><div class="ov">{icon("hrt","ic-sm")} 412</div></div>
    <div class="photo p11 cell"><div class="ov">{icon("hrt","ic-sm")} 398</div></div>
  </div>
</div>
''')

# ---------------- 51 单聊设置 ----------------
screen("51", "51-单聊设置", f'''
{statusbar()}
{nav("聊天信息")}
<div class="content">
  <div style="display:flex;flex-direction:column;align-items:center;padding:16px 0 4px;">
    <div class="ring"><div class="inner"><div class="av g1" style="width:72px;height:72px;font-size:22px;">豆</div></div></div>
    <div class="h2 mt2">小豆子</div>
    <div class="row gap2 mt1"><span class="badge-dot" style="background:var(--ok);"></span><span class="ter">在线</span></div>
  </div>
  <div class="card card-pad mt4" style="padding:4px 16px;">
    <div class="row gap3" style="padding:13px 0;"><div class="iconbox soft">{icon("usr","ic-sm")}</div><div style="flex:1;"><div class="h3" style="font-size:14px;">个人资料</div><div class="ter">昵称 · 签名 · 地区</div></div>{icon("cr","ic-sm")}</div>
    <div class="divider"></div>
    <div class="row gap3" style="padding:13px 0;"><div class="iconbox soft">{icon("dmd","ic-sm")}</div><div style="flex:1;"><div class="h3" style="font-size:14px;">查看 TA 的主页</div><div class="ter">作品 · 粉丝 · 关注</div></div>{icon("cr","ic-sm")}</div>
  </div>
  <div class="card card-pad mt4" style="padding:4px 16px;">
    <div class="row between" style="padding:14px 0;"><span class="h3" style="font-size:14px;">置顶聊天</span><span class="switch"></span></div>
    <div class="divider"></div>
    <div class="row between" style="padding:14px 0;"><span class="h3" style="font-size:14px;">消息免打扰</span><span class="switch off"></span></div>
    <div class="divider"></div>
    <div class="row between" style="padding:14px 0;"><span class="h3" style="font-size:14px;">消息通知</span><span class="switch"></span></div>
    <div class="divider"></div>
    <div class="row between" style="padding:14px 0;"><span class="h3" style="font-size:14px;">清空聊天记录</span>{icon("cr","ic-sm")}</div>
  </div>
  <div class="card card-pad mt4" style="padding:4px 16px;background:#FFF7F7;border-color:#FFE3E3;">
    <div class="row between" style="padding:13px 0;"><span class="h3" style="font-size:14px;color:var(--danger);">加入黑名单</span></div>
    <div class="divider" style="background:#FFE3E3;"></div>
    <div class="row between" style="padding:13px 0;"><span class="h3" style="font-size:14px;color:var(--danger);">删除会话</span></div>
    <div class="divider" style="background:#FFE3E3;"></div>
    <div class="row between" style="padding:13px 0;"><span class="h3" style="font-size:14px;color:var(--danger);">投诉</span></div>
  </div>
</div>
''')

# ---------------- 52 黑名单管理 ----------------
def _block_row(av, name, meta):
    return f'''<div class="row gap3" style="padding:12px 0;">
      <div class="av {av}">{name[0]}</div>
      <div style="flex:1;"><div class="h3" style="font-size:14px;">{name}</div><div class="ter">{meta}</div></div>
      <div class="btn btn-sm ghost" style="height:30px;font-size:12px;">解除拉黑</div>
    </div>'''

screen("52", "52-黑名单管理", f'''
{statusbar()}
{nav("黑名单")}
<div class="content">
  <div class="card-flat card-pad mb4" style="display:flex;align-items:center;gap:12px;">
    <div class="iconbox soft">{icon("lock","ic-sm")}</div>
    <div><div class="h3" style="font-size:14px;">拉黑后对方无法与你互动</div><div class="ter">不能发消息、评论和关注，共 3 人</div></div>
  </div>
  <div class="card card-pad" style="padding:4px 16px;">
    {_block_row("g3","果冻","拉黑于 08-03")}
    <div class="divider"></div>
    {_block_row("g5","新手村村民","拉黑于 07-28")}
    <div class="divider"></div>
    {_block_row("g6","拼豆研究所","拉黑于 07-20")}
  </div>
</div>
''')

# ---------------- 53 空状态示例 ----------------
def _empty(icon_cls, title, desc, btn):
    return f'''<div class="card-flat card-pad mb3" style="display:flex;flex-direction:column;align-items:center;gap:8px;padding:28px 16px;">
      <div style="width:56px;height:56px;border-radius:50%;background:var(--surface);display:flex;align-items:center;justify-content:center;color:var(--ter);">{icon(icon_cls,"ic-lg")}</div>
      <div class="h3" style="font-size:15px;">{title}</div>
      <div class="ter" style="font-size:12px;">{desc}</div>
      <div class="btn btn-sm black" style="margin-top:6px;height:34px;">{btn}</div>
    </div>'''

screen("53", "53-空状态示例", f'''
{statusbar()}
{nav("空状态组件")}
<div class="content">
  <div class="sec mb3">用于作品、收藏、通知、会话等列表无数据时</div>
  {_empty("cam","还没有作品","发布你的第一个手作作品吧","去发布")}
  {_empty("bmk","还没有收藏","看到喜欢的作品点收藏，会出现在这里","去逛逛")}
  <div class="row gap2" style="justify-content:center;padding:6px 0 2px;"><span class="ter" style="font-size:11px;">下拉查看更多空状态</span></div>
</div>
''')

# ---------------- 53b 空状态示例-续 ----------------
screen("53b", "53-空状态示例-续", f'''
{statusbar()}
{nav("空状态组件")}
<div class="content">
  <div style="text-align:center;padding:6px 0 4px;"><span class="ter" style="font-size:10px;">· 接上一页 ·</span></div>
  <div class="sec mb3">通知与会话列表无数据时的状态</div>
  {_empty("bl","暂无新通知","互动和系统消息都会提醒你","知道了")}
  {_empty("msg","还没有会话","添加好友开始聊天吧","添加好友")}
</div>
''')

# ---------------- 54 发布成功-审核中 ----------------
screen("54", "54-发布成功-审核中", f'''
{statusbar()}
<div class="content" style="text-align:center;padding-top:56px;">
  <div style="width:92px;height:92px;border-radius:50%;background:var(--ink);color:#fff;display:flex;align-items:center;justify-content:center;margin:0 auto 22px;">{icon("tick","ic-lg")}</div>
  <div class="h1" style="font-size:24px;">发布成功</div>
  <div class="sec mt2">作品已提交审核，审核通过后将展示在社区</div>
  <div class="card card-pad mt6" style="text-align:left;">
    <div class="row between mb3"><span class="sec">审核状态</span><span class="tag" style="background:var(--gradsoft);color:var(--ink);">审核中</span></div>
    <div class="row">
      <div class="row" style="flex-direction:column;align-items:center;gap:5px;flex:1;"><div style="width:26px;height:26px;border-radius:50%;background:var(--ink);color:#fff;display:flex;align-items:center;justify-content:center;">{icon("tick","ic-sm")}</div><span style="font-size:10px;">已提交</span></div>
      <div style="flex:1;height:2px;background:var(--ink);"></div>
      <div class="row" style="flex-direction:column;align-items:center;gap:5px;flex:1;"><div style="width:26px;height:26px;border-radius:50%;background:var(--ink);color:#fff;display:flex;align-items:center;justify-content:center;">{icon("clk","ic-sm")}</div><span style="font-size:10px;">审核中</span></div>
      <div style="flex:1;height:2px;background:var(--line);"></div>
      <div class="row" style="flex-direction:column;align-items:center;gap:5px;flex:1;"><div style="width:26px;height:26px;border-radius:50%;background:var(--surface);color:var(--ter);display:flex;align-items:center;justify-content:center;">{icon("fire","ic-sm")}</div><span style="font-size:10px;color:var(--ter);">已上架</span></div>
    </div>
    <div class="ter mt4" style="font-size:11px;text-align:center;">一般 5 分钟内完成审核，可在「我的内容」查看状态</div>
  </div>
  <div class="btn btn-black btn-block mt6">查看我的作品</div>
  <div class="btn btn-ghost btn-block mt3">返回社区</div>
</div>
''')

# ---------------- 55 作品全屏查看 ----------------
screen("55", "55-作品全屏查看", f'''
<div style="position:absolute;inset:0;background:#0D0D0F;">
  <div class="photo p5" style="position:absolute;left:0;right:0;top:0;height:560px;background:linear-gradient(160deg,#2C3E50,#4CA1AF);">
    <div style="position:absolute;inset:0;background:radial-gradient(circle at 50% 40%,rgba(255,255,255,.16),transparent 50%);"></div>
    <div style="position:absolute;left:12px;bottom:10px;color:#fff;font-size:11px;opacity:.85;">@小豆子 · 星空拼豆 2000 颗</div>
  </div>
  <div style="position:absolute;left:0;top:0;right:0;height:62px;display:flex;align-items:center;justify-content:space-between;padding:0 14px;color:#fff;z-index:5;">
    <span style="width:34px;height:34px;border-radius:50%;background:rgba(255,255,255,.16);display:flex;align-items:center;justify-content:center;">{icon("x","ic-sm")}</span>
    <span style="font-size:12px;background:rgba(0,0,0,.35);border-radius:10px;padding:3px 10px;">2 / 9</span>
    <span style="width:34px;height:34px;border-radius:50%;background:rgba(255,255,255,.16);display:flex;align-items:center;justify-content:center;">{icon("dots","ic-sm")}</span>
  </div>
  <div style="position:absolute;left:0;right:0;bottom:0;height:284px;background:linear-gradient(180deg,rgba(13,13,15,0),rgba(13,13,15,.96));padding:30px 16px 24px;color:#fff;">
    <div class="row gap3">
      <div class="ring"><div class="inner"><div class="av sm g1">豆</div></div></div>
      <div style="flex:1;"><div class="h3" style="font-size:15px;color:#fff;">小豆子</div><div class="ter" style="font-size:11px;color:rgba(255,255,255,.6);">08-06 · 上海</div></div>
      <div class="btn btn-sm black" style="height:32px;background:#fff;color:#141414;">关注</div>
    </div>
    <div class="mt3" style="font-size:14px;line-height:1.6;color:rgba(255,255,255,.92);">今天终于完成了 2000 颗拼豆的星空图！过程很治愈，附上成品和过程～ #拼豆 #星空</div>
    <div class="row gap4 mt4" style="color:#fff;">
      <div class="row gap1">{icon("hrt")}<b style="font-size:13px;">2.3k</b></div>
      <div class="row gap1">{icon("cmt")}<b style="font-size:13px;">86</b></div>
      <div class="row gap1">{icon("bmk")}<b style="font-size:13px;">412</b></div>
      <div style="flex:1;"></div>
      {icon("shr")}
    </div>
    <div class="row between mt4">
      <span class="ter" style="font-size:11px;color:rgba(255,255,255,.55);">左右滑动切换 · 双击缩放</span>
      <div class="vdots"><i></i><i class="on"></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i></div>
    </div>
  </div>
</div>
''')

# ---------------- 56 视频播放页 ----------------
screen("56", "56-视频播放页", f'''
<div style="position:absolute;inset:0;background:#0D0D0F;">
  <div class="photo p10" style="position:absolute;left:0;right:0;top:0;bottom:96px;background:linear-gradient(160deg,#3D2B45,#1A1A22);">
    <div style="position:absolute;inset:0;background:radial-gradient(circle at 60% 35%,rgba(255,255,255,.14),transparent 45%);"></div>
    <div style="position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);width:64px;height:64px;border-radius:50%;background:rgba(255,255,255,.92);display:flex;align-items:center;justify-content:center;color:#141414;">{icon("py","ic-lg")}</div>
  </div>
  <div style="position:absolute;left:0;top:0;right:0;height:62px;display:flex;align-items:center;justify-content:space-between;padding:0 14px;color:#fff;z-index:5;">
    <span style="width:34px;height:34px;border-radius:50%;background:rgba(255,255,255,.16);display:flex;align-items:center;justify-content:center;">{icon("x","ic-sm")}</span>
    <span style="font-size:14px;font-weight:600;">渐变拼豆新手教程</span>
    <span style="width:34px;height:34px;border-radius:50%;background:rgba(255,255,255,.16);display:flex;align-items:center;justify-content:center;">{icon("dots","ic-sm")}</span>
  </div>
  <div style="position:absolute;left:12px;bottom:118px;color:#fff;font-size:12px;opacity:.9;">@手作阿周 · 3 分钟学会渐变拼豆 #拼豆 #教程</div>
  <div style="position:absolute;left:0;right:0;bottom:0;height:96px;background:linear-gradient(180deg,rgba(13,13,15,0),rgba(13,13,15,.92));">
    <div class="pbar" style="margin:14px 16px 0;"><div class="buf"></div><div class="play"></div><div class="thumb"></div></div>
    <div class="row between mt3" style="padding:0 16px;">
      <div class="row gap1"><span style="color:#fff;font-size:12px;" class="num">00:24</span><span style="color:rgba(255,255,255,.5);font-size:12px;"> / 01:30</span></div>
      <div class="row gap4" style="color:#fff;">
        <span style="font-size:11px;background:rgba(255,255,255,.14);border-radius:8px;padding:2px 7px;">1.0x</span>
        {icon("mc","ic-sm")}
        <span style="width:18px;height:18px;border:1.5px solid #fff;border-radius:4px;position:relative;"><i style="position:absolute;left:4px;top:3px;width:8px;height:8px;background:#fff;border-radius:2px;clip-path:polygon(0 0,55% 0,55% 100%,0 100%);"></i></span>
        {icon("reel","ic-sm")}
      </div>
    </div>
  </div>
</div>
''')

# ---------------- 57 聊天图片查看 ----------------
screen("57", "57-聊天图片查看", f'''
<div style="position:absolute;inset:0;background:#0D0D0F;">
  <div class="photo p2" style="position:absolute;left:20px;right:20px;top:180px;height:400px;border-radius:16px;background:linear-gradient(160deg,#36D1DC,#5B86E5);">
    <div style="position:absolute;inset:0;background:radial-gradient(circle at 45% 35%,rgba(255,255,255,.18),transparent 48%);"></div>
    <div style="position:absolute;left:10px;bottom:10px;color:#fff;font-size:11px;text-shadow:0 1px 4px rgba(0,0,0,.4);">新到的星空拼豆配色 · 08-06 14:20</div>
  </div>
  <div style="position:absolute;left:0;top:0;right:0;height:62px;display:flex;align-items:center;justify-content:space-between;padding:0 14px;color:#fff;z-index:5;">
    <span style="width:34px;height:34px;border-radius:50%;background:rgba(255,255,255,.16);display:flex;align-items:center;justify-content:center;">{icon("x","ic-sm")}</span>
    <span style="font-size:12px;background:rgba(0,0,0,.35);border-radius:10px;padding:3px 10px;">图片</span>
    <span style="width:34px;height:34px;border-radius:50%;background:rgba(255,255,255,.16);display:flex;align-items:center;justify-content:center;">{icon("dots","ic-sm")}</span>
  </div>
  <div style="position:absolute;left:0;right:0;bottom:0;height:88px;background:linear-gradient(180deg,rgba(13,13,15,0),rgba(13,13,15,.9));display:flex;align-items:center;justify-content:space-around;color:#fff;padding-bottom:14px;">
    <div style="display:flex;flex-direction:column;align-items:center;gap:5px;">{icon("dl")}<span style="font-size:11px;">保存</span></div>
    <div style="display:flex;flex-direction:column;align-items:center;gap:5px;">{icon("shr")}<span style="font-size:11px;">转发</span></div>
    <div style="display:flex;flex-direction:column;align-items:center;gap:5px;">{icon("bmk")}<span style="font-size:11px;">收藏</span></div>
    <div style="display:flex;flex-direction:column;align-items:center;gap:5px;">{icon("dots")}<span style="font-size:11px;">更多</span></div>
  </div>
  <div style="position:absolute;left:50%;top:108px;transform:translateX(-50%);background:rgba(255,255,255,.14);color:#fff;font-size:11px;border-radius:14px;padding:5px 14px;">双击放大 · 长按弹出操作菜单</div>
</div>
''')

# ---------------- 58 图片查看-长按操作菜单 ----------------
screen("58", "58-图片查看-长按操作菜单", f'''
<div style="position:absolute;inset:0;background:#0D0D0F;">
  <div class="photo p2" style="position:absolute;left:20px;right:20px;top:180px;height:400px;border-radius:16px;background:linear-gradient(160deg,#36D1DC,#5B86E5);">
    <div style="position:absolute;inset:0;background:radial-gradient(circle at 45% 35%,rgba(255,255,255,.18),transparent 48%);"></div>
  </div>
  <div style="position:absolute;left:0;top:0;right:0;height:62px;display:flex;align-items:center;justify-content:space-between;padding:0 14px;color:#fff;z-index:5;">
    <span style="width:34px;height:34px;border-radius:50%;background:rgba(255,255,255,.16);display:flex;align-items:center;justify-content:center;">{icon("x","ic-sm")}</span>
    <span style="font-size:12px;background:rgba(0,0,0,.35);border-radius:10px;padding:3px 10px;">图片</span>
    <span style="width:34px;height:34px;border-radius:50%;background:rgba(255,255,255,.16);display:flex;align-items:center;justify-content:center;">{icon("dots","ic-sm")}</span>
  </div>
</div>
<div class="mask"></div>
<div class="sheet" style="padding-bottom:22px;">
  <div class="grab"></div>
  <div class="h3" style="text-align:center;margin-bottom:10px;">图片操作</div>
  <div class="row gap3" style="padding:13px 4px;"><div class="iconbox soft">{icon("dl","ic-sm")}</div><div style="flex:1;"><div class="h3" style="font-size:15px;">保存图片</div><div class="ter">保存到相册</div></div>{icon("cr","ic-sm")}</div>
  <div class="divider"></div>
  <div class="row gap3" style="padding:13px 4px;"><div class="iconbox soft">{icon("shr","ic-sm")}</div><div style="flex:1;"><div class="h3" style="font-size:15px;">转发给朋友</div><div class="ter">发送给会话或群聊</div></div>{icon("cr","ic-sm")}</div>
  <div class="divider"></div>
  <div class="row gap3" style="padding:13px 4px;"><div class="iconbox soft">{icon("img","ic-sm")}</div><div style="flex:1;"><div class="h3" style="font-size:15px;">设为聊天背景</div><div class="ter">仅对当前会话生效</div></div>{icon("cr","ic-sm")}</div>
  <div class="divider"></div>
  <div class="row gap3" style="padding:13px 4px;"><div class="iconbox soft">{icon("bmk","ic-sm")}</div><div style="flex:1;"><div class="h3" style="font-size:15px;">收藏</div><div class="ter">保存到我的收藏</div></div>{icon("cr","ic-sm")}</div>
  <div class="divider"></div>
  <div class="row gap3" style="padding:13px 4px;"><div class="iconbox soft">{icon("dots","ic-sm")}</div><div style="flex:1;"><div class="h3" style="font-size:15px;">更多</div><div class="ter">举报 / 识别图中内容</div></div>{icon("cr","ic-sm")}</div>
  <div class="btn btn-ghost btn-block" style="height:48px;border-radius:16px;margin-top:14px;">取消</div>
</div>
''')

# ---------------- 59 视频横屏全屏 ----------------
screen("59", "59-视频横屏全屏", f'''
<div style="position:absolute;inset:0;background:#0D0D0F;">
  <div class="photo p10" style="position:absolute;inset:0;background:linear-gradient(160deg,#3D2B45,#1A1A22);">
    <div style="position:absolute;inset:0;background:radial-gradient(circle at 60% 40%,rgba(255,255,255,.13),transparent 45%);"></div>
    <div style="position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);width:52px;height:52px;border-radius:50%;background:rgba(255,255,255,.92);display:flex;align-items:center;justify-content:center;color:#141414;">{icon("py")}</div>
  </div>
  <div style="position:absolute;left:0;top:0;right:0;height:52px;display:flex;align-items:center;justify-content:space-between;padding:0 18px;color:#fff;">
    <div class="row gap3">
      <span style="width:36px;height:36px;border-radius:50%;background:rgba(255,255,255,.16);display:flex;align-items:center;justify-content:center;">{icon("fs","ic-sm")}</span>
      <div><div style="font-size:14px;font-weight:600;">渐变拼豆新手教程</div><div style="font-size:11px;opacity:.7;margin-top:1px;">@手作阿周 · 拼豆教程</div></div>
    </div>
    <span style="width:36px;height:36px;border-radius:50%;background:rgba(255,255,255,.16);display:flex;align-items:center;justify-content:center;">{icon("dots","ic-sm")}</span>
  </div>
  <div style="position:absolute;left:0;right:0;bottom:0;height:72px;background:linear-gradient(180deg,rgba(13,13,15,0),rgba(13,13,15,.92));">
    <div class="row" style="align-items:center;gap:12px;padding:0 18px;height:72px;color:#fff;">
      <span style="width:34px;height:34px;border-radius:50%;background:rgba(255,255,255,.14);display:flex;align-items:center;justify-content:center;">{icon("pa","ic-sm")}</span>
      <div class="pbar" style="max-width:380px;"><div class="buf"></div><div class="play"></div><div class="thumb"></div></div>
      <span class="num" style="font-size:12px;">00:24 / 01:30</span>
      <span style="font-size:11px;background:rgba(255,255,255,.14);border-radius:8px;padding:2px 7px;">1.0x</span>
      <span style="width:30px;height:30px;border-radius:50%;background:rgba(255,255,255,.14);display:flex;align-items:center;justify-content:center;">{icon("mc","ic-sm")}</span>
      <span style="width:30px;height:30px;border-radius:50%;background:rgba(255,255,255,.14);display:flex;align-items:center;justify-content:center;">{icon("fs","ic-sm")}</span>
      <span style="width:30px;height:30px;border-radius:50%;background:rgba(255,255,255,.14);display:flex;align-items:center;justify-content:center;">{icon("dots","ic-sm")}</span>
    </div>
  </div>
</div>
''', w=844, h=390)

# ---------------- 60 横屏视频-竖屏显示 ----------------
screen("60", "60-横屏视频-竖屏显示", f'''
{statusbar()}
{nav("小豆子", right_html='<span class="badge-dot" style="background:var(--ok);"></span>')}
<div style="position:absolute;left:0;right:0;top:106px;bottom:74px;padding:16px;display:flex;flex-direction:column;gap:16px;">
  <div class="row gap2" style="align-items:flex-start;">
    <div class="av sm g1">豆</div>
    <div style="max-width:250px;background:var(--surface);border-radius:16px 16px 16px 4px;padding:10px 14px;font-size:14px;">分享今天拍的教程视频，横屏看效果更好</div>
  </div>
  <div class="row gap2" style="align-items:flex-start;">
    <div class="av sm g1">豆</div>
    <div style="width:300px;background:#141414;border-radius:16px 16px 16px 4px;overflow:hidden;">
      <div style="position:relative;height:169px;background:#000;">
        <div style="position:absolute;left:0;right:0;top:30px;bottom:30px;background:linear-gradient(160deg,#36D1DC,#5B86E5);"></div>
        <div style="position:absolute;inset:0;background:radial-gradient(circle at 55% 40%,rgba(255,255,255,.16),transparent 45%);"></div>
        <div style="position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);width:40px;height:40px;border-radius:50%;background:rgba(255,255,255,.92);display:flex;align-items:center;justify-content:center;color:#141414;">{icon("py","ic-sm")}</div>
        <span style="position:absolute;right:8px;bottom:6px;background:rgba(0,0,0,.6);color:#fff;border-radius:6px;padding:1px 7px;font-size:10px;" class="num">01:30</span>
      </div>
      <div class="row between" style="padding:10px 12px;">
        <div><div style="font-size:13px;font-weight:600;color:#fff;">渐变拼豆新手教程</div><div style="font-size:10px;color:rgba(255,255,255,.55);margin-top:1px;">横屏视频 · 建议横屏观看</div></div>
        <div style="display:flex;flex-direction:column;align-items:center;gap:3px;color:#fff;"><span style="width:30px;height:30px;border-radius:50%;background:rgba(255,255,255,.16);display:flex;align-items:center;justify-content:center;">{icon("rot","ic-sm")}</span><span style="font-size:9px;">旋转观看</span></div>
      </div>
    </div>
  </div>
</div>
{chat_input()}
''')

# ---------------- 61 聊天输入-功能面板 ----------------
screen("61", "61-聊天输入-功能面板", f'''
{statusbar()}
{nav("小豆子", right_html='<span class="badge-dot" style="background:var(--ok);"></span>')}
<div style="position:absolute;left:0;right:0;top:106px;bottom:74px;padding:16px;display:flex;flex-direction:column;gap:16px;">
  <div class="row gap2" style="align-items:flex-start;">
    <div class="av sm g1">豆</div>
    <div style="max-width:250px;background:var(--surface);border-radius:16px 16px 16px 4px;padding:10px 14px;font-size:14px;">晚上一起吃饭吗？</div>
  </div>
  <div style="display:flex;justify-content:flex-end;">
    <div style="max-width:250px;background:var(--ink);color:#fff;border-radius:16px 16px 4px 16px;padding:10px 14px;font-size:14px;">好啊，7 点在万象城见</div>
  </div>
</div>
<div style="position:absolute;left:0;right:0;bottom:0;height:74px;border-top:1px solid var(--line);background:#fff;display:flex;align-items:center;padding:0 10px;gap:6px;z-index:5;">
  <div style="color:var(--sec);flex:none;width:34px;display:flex;justify-content:center;">{icon("mc","ic-sm")}</div>
  <div class="field" style="flex:1;height:42px;border-radius:21px;outline:1.5px solid var(--ink);"><span style="font-size:13px;color:var(--ink);">晚上一起吃饭吗？</span></div>
  <div style="color:var(--sec);flex:none;width:34px;display:flex;justify-content:center;">{icon("emoji","ic-sm")}</div>
  <div class="btn btn-black btn-sm" style="height:36px;">发送</div>
</div>
<div style="position:absolute;left:0;right:0;bottom:74px;height:200px;background:#F7F7F8;border-top:1px solid var(--line);padding:16px 14px 0;">
  <div class="row" style="justify-content:space-between;margin-bottom:18px;">
    <div class="func-cell"><div class="fc">{icon("grd")}</div><span>相册</span></div>
    <div class="func-cell"><div class="fc">{icon("cam")}</div><span>拍摄</span></div>
    <div class="func-cell"><div class="fc">{icon("pin")}</div><span>位置</span></div>
    <div class="func-cell"><div class="fc">{icon("mc")}</div><span>语音输入</span></div>
  </div>
  <div class="row" style="justify-content:space-between;">
    <div class="func-cell"><div class="fc">{icon("reel")}</div><span>视频</span></div>
    <div class="func-cell"><div class="fc">{icon("bmk")}</div><span>收藏</span></div>
    <div class="func-cell"><div class="fc">{icon("mus")}</div><span>音乐</span></div>
    <div class="func-cell"><div class="fc">{icon("dots")}</div><span>更多</span></div>
  </div>
</div>
''')

# ---------------- 62 聊天输入-表情面板 ----------------
def _eface(variant=""):
    return f'<div class="eface {variant}"><i></i><i></i><i class="m"></i></div>'

screen("62", "62-聊天输入-表情面板", f'''
{statusbar()}
{nav("小豆子", right_html='<span class="badge-dot" style="background:var(--ok);"></span>')}
<div style="position:absolute;left:0;right:0;top:106px;bottom:74px;padding:16px;display:flex;flex-direction:column;gap:16px;">
  <div class="row gap2" style="align-items:flex-start;">
    <div class="av sm g1">豆</div>
    <div style="max-width:250px;background:var(--surface);border-radius:16px 16px 16px 4px;padding:10px 14px;font-size:14px;">哈哈 太好笑了</div>
  </div>
  <div style="display:flex;justify-content:flex-end;">
    <div style="max-width:250px;background:var(--ink);color:#fff;border-radius:16px 16px 4px 16px;padding:10px 14px;font-size:14px;">真的吗？我拍给你看</div>
  </div>
</div>
<div style="position:absolute;left:0;right:0;bottom:0;height:74px;border-top:1px solid var(--line);background:#fff;display:flex;align-items:center;padding:0 10px;gap:6px;z-index:5;">
  <div style="color:var(--sec);flex:none;width:34px;display:flex;justify-content:center;">{icon("mc","ic-sm")}</div>
  <div class="field" style="flex:1;height:42px;border-radius:21px;"><span class="ph" style="font-size:13px;">发送消息…</span></div>
  <div style="background:var(--ink);color:#fff;flex:none;width:34px;height:34px;border-radius:50%;display:flex;align-items:center;justify-content:center;">{icon("emoji","ic-sm")}</div>
  <div style="color:var(--sec);flex:none;width:34px;display:flex;justify-content:center;">{icon("pl","ic-sm")}</div>
</div>
<div style="position:absolute;left:0;right:0;bottom:74px;height:210px;background:#F7F7F8;border-top:1px solid var(--line);padding:12px 12px 0;">
  <div class="row gap2" style="margin-bottom:12px;">
    <div class="chip sm on" style="height:24px;font-size:11px;">最近</div>
    <div class="chip sm" style="height:24px;font-size:11px;">经典</div>
    <div class="chip sm" style="height:24px;font-size:11px;">动物</div>
    <div class="chip sm" style="height:24px;font-size:11px;">手势</div>
    <div style="flex:1;"></div>
    {icon("x","ic-sm")}
  </div>
  <div class="row" style="justify-content:space-between;margin-bottom:14px;">
    {_eface()}{_eface("o")}{_eface("w")}{_eface("x")}
  </div>
  <div class="row" style="justify-content:space-between;margin-bottom:14px;">
    {_eface("o")}{_eface()}{_eface("x")}{_eface("w")}
  </div>
  <div class="row between">
    <span class="ter" style="font-size:11px;">长按表情可设置快捷表情</span>
    <div class="btn btn-black btn-sm" style="height:32px;">发送</div>
  </div>
</div>
''')

# ---------------- 63 聊天输入-语音长按 ----------------
screen("63", "63-聊天输入-语音长按", f'''
{statusbar()}
{nav("小豆子", right_html='<span class="badge-dot" style="background:var(--ok);"></span>')}
<div class="toast">松开发送 · 上滑取消</div>
<div style="position:absolute;left:0;right:0;top:106px;bottom:74px;padding:16px;display:flex;flex-direction:column;gap:16px;">
  <div class="row gap2" style="align-items:flex-start;">
    <div class="av sm g1">豆</div>
    <div style="max-width:250px;background:var(--surface);border-radius:16px 16px 16px 4px;padding:10px 14px;font-size:14px;">语音方便点，我按着说</div>
  </div>
  <div style="display:flex;justify-content:flex-end;">
    <div style="max-width:250px;background:var(--ink);color:#fff;border-radius:16px 16px 4px 16px;padding:10px 14px;font-size:14px;">好呀，你直接说就行</div>
  </div>
</div>
<div style="position:absolute;left:0;right:0;bottom:0;height:74px;border-top:1px solid var(--line);background:#fff;display:flex;align-items:center;padding:0 10px;gap:6px;z-index:5;">
  <div style="background:var(--ink);color:#fff;flex:none;width:34px;height:34px;border-radius:50%;display:flex;align-items:center;justify-content:center;">{icon("mc","ic-sm")}</div>
  <div style="flex:1;height:42px;border-radius:21px;background:var(--surface);display:flex;align-items:center;justify-content:center;gap:8px;font-size:14px;font-weight:600;color:var(--ink);">{icon("mc","ic-sm")}<span>按住 说话</span></div>
  <div style="color:var(--sec);flex:none;width:34px;display:flex;justify-content:center;">{icon("emoji","ic-sm")}</div>
  <div style="color:var(--sec);flex:none;width:34px;display:flex;justify-content:center;">{icon("pl","ic-sm")}</div>
</div>
''')

# ---------------- assembly ----------------
PITCH_Y = 900
GAP = 40
GRID_W = 2150

def _layout():
    px = 0
    py = 0
    slots = []
    for s in SCREENS:
        w = s["w"]
        if px + w > GRID_W:
            px = 0
            py += PITCH_Y
        slots.append((px, py))
        px += w + GAP
    return slots, py + PITCH_Y

slots, GRID_H = _layout()
parts = [f'<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><style>{CSS}</style></head><body style="width:{GRID_W}px;height:{GRID_H}px;">']
for s, (left, top) in zip(SCREENS, slots):
    parts.append(f'<div class="screen" id="{s["sid"]}" style="left:{left}px;top:{top}px;width:{s["w"]}px;height:{s["h"]}px;">{s["body"]}</div>')
parts.append('</body></html>')

OUT = os.path.join(HERE, "screens", "all.html")
os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT, "w", encoding="utf-8") as f:
    f.write("\n".join(parts))

print(f"OK {len(SCREENS)} screens -> {OUT}")
