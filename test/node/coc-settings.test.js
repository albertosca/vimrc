/**
 * IT-021 a IT-026, IT-085, IT-026b: Validação de coc-settings.json
 */

const fs   = require('fs');
const path = require('path');
const os   = require('os');

// Resolve o caminho, expandindo ~ manualmente (Node não expande ~ nativamente)
function expandHome(p) {
  return p.startsWith('~') ? path.join(os.homedir(), p.slice(1)) : p;
}

const COC_SETTINGS_PATH = expandHome('~/.vim/coc-settings.json');

let settings;

// IT-021 — JSON válido
describe('IT-021: coc-settings.json é JSON válido', () => {
  test('arquivo existe', () => {
    expect(fs.existsSync(COC_SETTINGS_PATH)).toBe(true);
  });

  test('parse sem erros', () => {
    const raw = fs.readFileSync(COC_SETTINGS_PATH, 'utf8');
    expect(() => {
      settings = JSON.parse(raw);
    }).not.toThrow();
  });
});

// Garante que settings está carregado para os testes seguintes
beforeAll(() => {
  const raw = fs.readFileSync(COC_SETTINGS_PATH, 'utf8');
  settings = JSON.parse(raw);
});

// IT-022 — eslint.autoFixOnSave é boolean true
describe('IT-022: eslint.autoFixOnSave', () => {
  test('é boolean (não string)', () => {
    expect(typeof settings['eslint.autoFixOnSave']).toBe('boolean');
  });

  test('é true', () => {
    expect(settings['eslint.autoFixOnSave']).toBe(true);
  });
});

// IT-023 — elixir.pathToElixirLS aponta para arquivo existente
// Nota: toHaveProperty interpreta pontos como caminho aninhado — usar acesso direto
describe('IT-023: elixir.pathToElixirLS', () => {
  test('chave presente no JSON', () => {
    expect(settings['elixir.pathToElixirLS']).toBeDefined();
  });

  test('caminho expandido existe no sistema', () => {
    const raw = settings['elixir.pathToElixirLS'];
    const resolved = expandHome(raw);
    expect(fs.existsSync(resolved)).toBe(true);
  });
});

// IT-024 — tailwindCSS.includeLanguages cobre heex e eruby
describe('IT-024: tailwindCSS.includeLanguages', () => {
  let langs;

  beforeAll(() => {
    langs = settings['tailwindCSS.includeLanguages'] || {};
  });

  test('chave presente no JSON', () => {
    expect(settings['tailwindCSS.includeLanguages']).toBeDefined();
  });

  test('heex mapeado para "html"', () => {
    expect(langs['heex']).toBe('html');
  });

  test('eruby mapeado para "html"', () => {
    expect(langs['eruby']).toBe('html');
  });
});

// IT-025 — emmet.includeLanguages cobre javascriptreact e typescriptreact
describe('IT-025: emmet.includeLanguages', () => {
  let langs;

  beforeAll(() => {
    langs = settings['emmet.includeLanguages'] || {};
  });

  test('chave presente no JSON', () => {
    expect(settings['emmet.includeLanguages']).toBeDefined();
  });

  test('javascriptreact mapeado para "html"', () => {
    expect(langs['javascriptreact']).toBe('html');
  });

  test('typescriptreact mapeado para "html"', () => {
    expect(langs['typescriptreact']).toBe('html');
  });
});

// IT-026 — python.pythonPath ausente (depreciado desde CoC 0.0.80+)
describe('IT-026: python.pythonPath ausente (depreciado)', () => {
  test('python.pythonPath NÃO deve estar presente', () => {
    // Chave depreciada — causa aviso do CoC ao iniciar. Bug detectado em 2026-04-15.
    expect(
      Object.prototype.hasOwnProperty.call(settings, 'python.pythonPath')
    ).toBe(false);
  });
});

// IT-026b — substituto correto presente
describe('IT-026b: python.defaultInterpreterPath presente (substituto correto)', () => {
  test('python.defaultInterpreterPath deve estar definido', () => {
    expect(settings['python.defaultInterpreterPath']).toBeDefined();
  });

  test('valor aponta para um interpretador python', () => {
    const val = settings['python.defaultInterpreterPath'];
    expect(typeof val).toBe('string');
    expect(val.length).toBeGreaterThan(0);
  });
});

// IT-085 — elixirLS.dialyzerEnabled é boolean, não string
describe('IT-085: elixirLS.dialyzerEnabled', () => {
  test('chave presente no JSON', () => {
    expect(settings['elixirLS.dialyzerEnabled']).toBeDefined();
  });

  test('é boolean (não string "true")', () => {
    expect(typeof settings['elixirLS.dialyzerEnabled']).toBe('boolean');
  });
});

// IT-116 — Ruby LSP configurado como language server
describe('IT-119: Ruby LSP (languageserver.ruby-lsp)', () => {
  test('languageserver definido no JSON', () => {
    expect(settings['languageserver']).toBeDefined();
  });

  test('ruby-lsp presente em languageserver', () => {
    expect(settings['languageserver']['ruby-lsp']).toBeDefined();
  });

  test('ruby-lsp command é ruby-lsp', () => {
    const rubyLsp = settings['languageserver']['ruby-lsp'];
    expect(rubyLsp.command).toBe('ruby-lsp');
  });

  test('ruby-lsp cobre filetypes ruby e eruby', () => {
    const ft = settings['languageserver']['ruby-lsp'].filetypes;
    expect(ft).toContain('ruby');
    expect(ft).toContain('eruby');
  });
});

// IT-120 — Inlay hints habilitados para Go, TS e Python
describe('IT-120: Inlay hints habilitados', () => {
  test('Go inlay hints para parameter names', () => {
    expect(settings['go.inlayHints.parameterNames']).toBe(true);
  });

  test('TypeScript inlay hints para parameter names', () => {
    const val = settings['typescript.inlayHints.parameterNames.enabled'];
    expect(val).toBeDefined();
    expect(val).not.toBe('none');
  });

  test('JavaScript inlay hints para parameter names', () => {
    const val = settings['javascript.inlayHints.parameterNames.enabled'];
    expect(val).toBeDefined();
    expect(val).not.toBe('none');
  });
});
