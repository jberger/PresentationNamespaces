use Mojolicious::Lite;

plugin 'RevealJS';

any '/' => 'shell';

app->start;

__DATA__

@@ revealjs_preinit.js.ep

init.dependencies[3] = { src: 'revealjs/plugin/highlight/highlight.js', async: true, callback: function() { hljs.initHighlightingOnLoad(); } },

@@ shell.html.ep

% layout 'revealjs';

<section data-markdown="presentation.md"></section>

