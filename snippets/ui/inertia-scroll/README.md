# momentum-scroll

Efeito de inércia no scroll usando `lerp` puro, sem dependências. A página desliza suavemente até parar, como uma patinação no gelo.

---

## Como aplicar em qualquer projeto

### 1. HTML — dois elementos obrigatórios

Adicione fora do seu conteúdo principal:

```html
<!-- Fora do scroller, direto no body -->
<div id="proxy"></div>

<!-- Envolve TODO o conteúdo da página -->
<div id="scroller">
  <!-- seu conteúdo aqui -->
</div>
```

**Por que o `#proxy`:** o `#scroller` é `position: fixed`, então a página não tem altura — o browser não gera scrollbar. O proxy é uma div invisível com a mesma altura do conteúdo que engana o browser e ativa o scroll nativo.

**Por que o `#scroller` é fixed:** para poder mover o conteúdo inteiro com `translateY` sem depender do scroll nativo, que é abrupto.

---

### 2. CSS — três regras essenciais

```css
/* Impede scroll horizontal indesejado,
   mas não trave o vertical — o proxy cuida disso */
html, body {
  overflow-x: hidden;
}

/* Container fixo que vai ser movido pelo JS */
#scroller {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  will-change: transform; /* avisa a GPU que vai animar */
}

/* Proxy invisível — sem isso o scroll não funciona */
#proxy {
  position: absolute;
  top: 0;
  left: 0;
  width: 1px;
  pointer-events: none;
}
```

**Por que `will-change: transform`:** avisa o browser para criar um layer de composição separado na GPU para o scroller. Evita repaint a cada frame e mantém 60fps mesmo em páginas pesadas.

---

### 3. JavaScript — lógica completa

Cole isso antes do `</body>`:

```js
const scroller = document.getElementById('scroller');
const proxy    = document.getElementById('proxy');

// Sincroniza a altura do proxy com o conteúdo real
function syncHeight() {
  proxy.style.height = scroller.scrollHeight + 'px';
}
syncHeight();
window.addEventListener('resize', syncHeight);

let current = 0; // posição atual suavizada (o que o usuário vê)
let target  = 0; // posição real do scroll nativo

// Captura o scroll nativo (gerado pelo proxy)
window.addEventListener('scroll', () => {
  target = window.scrollY;
});

// Interpolação linear: move current X% em direção ao target a cada frame
const lerp = (a, b, t) => a + (b - a) * t;

const LERP_FACTOR = 0.07; // ajuste aqui (ver tabela abaixo)

(function loop() {
  current = lerp(current, target, LERP_FACTOR);
  scroller.style.transform = `translateY(${-current}px)`;
  requestAnimationFrame(loop);
})();
```

---

## Ajustando o feeling

| `LERP_FACTOR` | Efeito |
|---|---|
| `0.04` | gelo — deslize longo e lento |
| `0.07` | patinação — padrão recomendado |
| `0.12` | suave — bom para sites de conteúdo |
| `0.25` | leve — quase imperceptível |

A lógica: a cada frame, `current` percorre `LERP_FACTOR * distância_restante`. Com `0.07` e 60fps, o deslize dura ~350ms. Quanto menor o fator, mais frames para chegar ao destino, mais suave o efeito.

---

## Compatibilidade

- Funciona em qualquer página HTML, com ou sem frameworks
- Não interfere em `position: fixed` — elementos fixos continuam fixos normalmente porque estão fora do `#scroller` ou são filhos do fixed
- Para elementos que precisam ficar fora do efeito (navbars, modais, cursores), coloque-os **fora do `#scroller`**, direto no `body`

---

## O que não copiar

O arquivo de referência contém cursor customizado, velocímetro e layout de demonstração — são visuais de teste, não fazem parte da técnica. A lógica de scroll está isolada nas seções marcadas acima.
