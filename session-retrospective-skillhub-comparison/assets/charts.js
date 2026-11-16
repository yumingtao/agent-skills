(function() {
  var style = getComputedStyle(document.documentElement);
  var accent = style.getPropertyValue('--accent').trim();
  var accent2 = style.getPropertyValue('--accent2').trim();
  var ink = style.getPropertyValue('--ink').trim();
  var muted = style.getPropertyValue('--muted').trim();
  var rule = style.getPropertyValue('--rule').trim();
  var bg2 = style.getPropertyValue('--bg2').trim();

  // --- Chart 1: competitor downloads bar ---
  var chart1 = echarts.init(document.getElementById('chart-downloads'), null, { renderer: 'svg' });
  chart1.setOption({
    animation: false,
    backgroundColor: 'transparent',
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'shadow' },
      appendToBody: true,
      backgroundColor: bg2,
      borderColor: rule,
      textStyle: { color: ink },
      formatter: function(params) {
        var p = params[0];
        var extra = p.data.detail;
        return '<b>' + p.name + '</b><br/>下载量：' + p.value.toLocaleString() +
          '<br/>AI 评分：' + extra.score + ' / 5.0' +
          '<br/>收藏：' + extra.favs + ' · ' + extra.version + ' · ' + extra.age;
      }
    },
    grid: { left: 170, right: 60, top: 20, bottom: 30 },
    xAxis: {
      type: 'value',
      axisLabel: { color: muted, fontFamily: 'GeistMono, monospace' },
      splitLine: { lineStyle: { color: rule } }
    },
    yAxis: {
      type: 'category',
      inverse: true,
      data: ['retrospective-lesson', 'ai-retrospective-skill', '复盘助理', 'self-reivew-pro'],
      axisLabel: { color: ink, fontSize: 13 },
      axisLine: { lineStyle: { color: rule } }
    },
    series: [{
      type: 'bar',
      data: [
        { value: 589, detail: { score: 4.8, favs: 0, version: 'v1.5.0', age: '4 个月前更新' }, itemStyle: { color: muted } },
        { value: 707, detail: { score: 4.5, favs: 0, version: 'v1.0.0', age: '7 个月前更新' }, itemStyle: { color: muted } },
        { value: 3600, detail: { score: 4.6, favs: 1, version: 'v1.0.0', age: '5 个月前更新' }, itemStyle: { color: accent2 } },
        { value: 8800, detail: { score: 4.3, favs: 5, version: 'v1.0.0', age: '7 个月前更新' }, itemStyle: { color: accent } }
      ],
      barWidth: '55%',
      label: {
        show: true,
        position: 'right',
        color: muted,
        fontFamily: 'GeistMono, monospace',
        formatter: function(p) { return p.value.toLocaleString(); }
      },
      itemStyle: { borderRadius: [0, 4, 4, 0] }
    }]
  });
  window.addEventListener('resize', function() { chart1.resize(); });

  // --- Chart 2: capability radar ---
  var chart2 = echarts.init(document.getElementById('chart-radar'), null, { renderer: 'svg' });
  chart2.setOption({
    animation: false,
    backgroundColor: 'transparent',
    legend: {
      bottom: 0,
      textStyle: { color: muted },
      data: ['session-retrospective（本技能）', 'ai-retrospective-skill', 'retrospective-lesson']
    },
    tooltip: { appendToBody: true, backgroundColor: bg2, borderColor: rule, textStyle: { color: ink } },
    radar: {
      indicator: [
        { name: '结构化数据输出', max: 5 },
        { name: '复发检测与\n优先级升级', max: 5 },
        { name: '反编造与\n诚实降级', max: 5 },
        { name: '异常场景覆盖', max: 5 },
        { name: '更新闭环', max: 5 },
        { name: '多平台兼容', max: 5 }
      ],
      center: ['50%', '48%'],
      radius: '62%',
      axisName: { color: ink, fontSize: 12 },
      splitLine: { lineStyle: { color: rule } },
      splitArea: { areaStyle: { color: ['transparent', 'rgba(83,166,255,0.03)'] } },
      axisLine: { lineStyle: { color: rule } }
    },
    series: [{
      type: 'radar',
      data: [
        {
          name: 'session-retrospective（本技能）',
          value: [5, 5, 5, 5, 3, 5],
          lineStyle: { color: accent, width: 2.5 },
          itemStyle: { color: accent },
          areaStyle: { color: 'rgba(83,166,255,0.18)' }
        },
        {
          name: 'ai-retrospective-skill',
          value: [2, 1, 1, 3, 3, 2],
          lineStyle: { color: accent2, width: 1.5 },
          itemStyle: { color: accent2 },
          areaStyle: { color: 'rgba(255,180,84,0.08)' }
        },
        {
          name: 'retrospective-lesson',
          value: [2, 2, 4, 3, 5, 4],
          lineStyle: { color: muted, width: 1.5 },
          itemStyle: { color: muted },
          areaStyle: { color: 'rgba(147,161,181,0.05)' }
        }
      ]
    }]
  });
  window.addEventListener('resize', function() { chart2.resize(); });

  // --- Mermaid init (dark) ---
  if (window.mermaid) {
    mermaid.initialize({ startOnLoad: true, theme: 'dark', securityLevel: 'loose' });
  }
})();
