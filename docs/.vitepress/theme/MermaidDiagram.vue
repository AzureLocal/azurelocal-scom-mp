<script setup lang="ts">
import mermaid from 'mermaid'
import { onMounted, ref, watch } from 'vue'
import { useData } from 'vitepress'

const props = defineProps<{
  graph: string
  id: string
}>()

const { isDark } = useData()
const svg = ref('')
const error = ref('')
let renderNumber = 0

async function renderDiagram() {
  const currentRender = ++renderNumber
  error.value = ''

  try {
    mermaid.initialize({
      startOnLoad: false,
      securityLevel: 'strict',
      theme: isDark.value ? 'dark' : 'neutral',
    })

    const result = await mermaid.render(
      `${props.id}-${currentRender}`,
      decodeURIComponent(props.graph),
    )

    if (currentRender === renderNumber) {
      svg.value = result.svg
    }
  } catch (caught) {
    if (currentRender === renderNumber) {
      error.value = caught instanceof Error ? caught.message : String(caught)
    }
  }
}

onMounted(renderDiagram)
watch(isDark, renderDiagram)
</script>

<template>
  <div v-if="svg" class="mermaid-diagram" v-html="svg" />
  <pre v-else-if="error" class="mermaid-error">Diagram could not be rendered: {{ error }}</pre>
  <div v-else class="mermaid-loading" aria-live="polite">Rendering diagram…</div>
</template>

<style scoped>
.mermaid-diagram {
  margin: 1.5rem 0;
  overflow-x: auto;
  text-align: center;
}

.mermaid-diagram :deep(svg) {
  height: auto;
  max-width: 100%;
}

.mermaid-error {
  overflow-x: auto;
  color: var(--vp-c-danger-1);
  white-space: pre-wrap;
}

.mermaid-loading {
  color: var(--vp-c-text-2);
  padding: 1.5rem 0;
  text-align: center;
}
</style>
