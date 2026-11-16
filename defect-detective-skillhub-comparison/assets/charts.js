(function() {
  var style = getComputedStyle(document.documentElement);
  var accent = style.getPropertyValue('--accent').trim();
  var accent2 = style.getPropertyValue('--accent2').trim();
  var ink = style.getPropertyValue('--ink').trim();
  var muted = style.getPropertyValue('--muted').trim();
  var rule = style.getPropertyValue('--rule').trim();
  var bg2 = style.getPropertyValue('--bg2').trim();

  // --- Chart 1: downloads (log axis bar) ---
  var dlNames = ['bug-fixer-ultimate', 'bug-fix-farming', 'debug-java', 'debug-pro',
                 'bugfix-root-cause-copilot', 'debug-session', 'bug-zoo',
                 'debugging-and-error-recovery', 'bug-analysis', 'bug-triage-digest',
                 'debug-triage-zh', 'dev-bug-detective'];
  var dlValues = [11400, 5200, 3809, 2700, 1821, 1763, 1368, 602, 569, 536, 102, 159];
  // amber highlight: skills directly related to triage/dedup positioning
  var dlHighlight = [0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1];
  var dlChart = echarts.init(document.getElementById('chart-downloads'), null, { renderer: 'svg' });
  dlChart.setOption({
    animation: false,
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' }, appendToBody: true },
    grid: { left: 170, right: 60, top: 20, bottom: 40 },
    xAxis: {
      type: 'log',
      logBase: 10,
      min: 50,
      axisLine: { lineStyle: { color: rule } },
      axisLabel: { color: muted, formatter: function(v) { return v >= 1000 ? (v / 1000) + 'K' : v; } },
      splitLine: { lineStyle: { color: rule, opacity: 0.4 } }
    },
    yAxis: {
      type: 'category',
      data: dlNames.reverse().map(function(n) { return n; }),
      axisLine: { lineStyle: { color: rule } },
      axisLabel: { color: ink, fontSize: 12 }
    },
    series: [{
      type: 'bar',
      data: dlValues.reverse().map(function(v, i) {
        var isHl = dlHighlight[dlHighlight.length - 1 - i] === 1;
        return { value: v, itemStyle: { color: isHl ? accent2 : accent, borderRadius: [0, 3, 3, 0] } };
      }),
      barMaxWidth: 18,
      label: { show: true, position: 'right', color: muted, fontSize: 11,
               formatter: function(p) { return p.value >= 1000 ? (p.value / 1000).toFixed(1) + 'K' : p.value; } }
    }]
  });
  window.addEventListener('resize', function() { dlChart.resize(); });

  // --- Chart 2: AI scores ---
  var scNames = ['bug-fix-farming', 'bug-triage-digest', 'debug-pro', 'dev-bug-detective'];
  var scValues = [4.7, 4.7, 4.6, 4.4];
  var scChart = echarts.init(document.getElementById('chart-scores'), null, { renderer: 'svg' });
  scChart.setOption({
    animation: false,
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' }, appendToBody: true },
    grid: { left: 170, right: 70, top: 20, bottom: 40 },
    xAxis: {
      type: 'value', min: 4.0, max: 5.0,
      axisLine: { lineStyle: { color: rule } },
      axisLabel: { color: muted },
      splitLine: { lineStyle: { color: rule, opacity: 0.4 } }
    },
    yAxis: {
      type: 'category', data: scNames.reverse(),
      axisLine: { lineStyle: { color: rule } },
      axisLabel: { color: ink, fontSize: 12 }
    },
    series: [{
      type: 'bar',
      data: scValues.reverse(),
      barMaxWidth: 20,
      itemStyle: { color: accent, borderRadius: [0, 3, 3, 0] },
      label: { show: true, position: 'right', color: accent2, fontWeight: 600, fontSize: 13,
               formatter: function(p) { return p.value.toFixed(1); } }
    }]
  });
  window.addEventListener('resize', function() { scChart.resize(); });

  // --- Chart 3: radar ---
  var radarChart = echarts.init(document.getElementById('chart-radar'), null, { renderer: 'svg' });
  radarChart.setOption({
    animation: false,
    tooltip: { appendToBody: true },
    legend: {
      bottom: 0,
      textStyle: { color: muted, fontSize: 12 },
      itemWidth: 14, itemHeight: 9
    },
    radar: {
      indicator: [
        { name: '只读安全', max: 5 },
        { name: '查重能力', max: 5 },
        { name: '归属推断', max: 5 },
        { name: '变更关联', max: 5 },
        { name: '证据可审计', max: 5 },
        { name: '流程严谨', max: 5 },
        { name: '文档完整度', max: 5 }
      ],
      radius: '62%',
      center: ['50%', '47%'],
      axisName: { color: ink, fontSize: 12 },
      splitLine: { lineStyle: { color: rule } },
      splitArea: { show: false },
      axisLine: { lineStyle: { color: rule } }
    },
    series: [{
      type: 'radar',
      data: [
        {
          name: 'defect-detective',
          value: [5, 5, 5, 4, 5, 4, 5],
          lineStyle: { color: accent2, width: 2.5 },
          itemStyle: { color: accent2 },
          areaStyle: { color: accent2, opacity: 0.25 }
        },
        {
          name: 'bug-fix-farming',
          value: [3, 0, 0, 1, 2, 5, 4],
          lineStyle: { color: accent, width: 1.5 },
          itemStyle: { color: accent },
          areaStyle: { color: accent, opacity: 0.08 }
        },
        {
          name: 'debug-pro',
          value: [2, 0, 0, 2, 1, 4, 5],
          lineStyle: { color: muted, width: 1.5 },
          itemStyle: { color: muted },
          areaStyle: { color: muted, opacity: 0.05 }
        },
        {
          name: 'bug-triage-digest',
          value: [5, 0, 0, 0, 3, 4, 5],
          lineStyle: { color: accent, width: 1.5, type: 'dashed' },
          itemStyle: { color: accent },
          areaStyle: { color: accent, opacity: 0.05 }
        },
        {
          name: 'dev-bug-detective',
          value: [1, 0, 0, 3, 1, 2, 2],
          lineStyle: { color: muted, width: 1.5, type: 'dashed' },
          itemStyle: { color: muted }
        }
      ]
    }]
  });
  window.addEventListener('resize', function() { radarChart.resize(); });
})();
