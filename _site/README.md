# Tok3n User Signup

## Building the project.
1. If Jekyll and Compass aren't already installed, install them (`gem install jekyll` and `gem install compass`)
2. In the **root** of the project, run `jekyll serve --watch --baseurl /`
3. In the **_sass** directory, run `compass watch`
4. Point your browser at localhost:4000

## Jekyll Project Structure
Jekyll builds projects from component parts into a static HTML site, which is in the **_site** directory. Don't edit any files in there, they'll get overwritten each time Jekyll builds. A leading underscore in a file or folder name indicates to Jekyll to not output that file/directory into the generated _site. 

Jekyll uses the [Liquid](http://liquidmarkup.org/) templating engine. The most important Liquid feature used here is `{% include %}`. The include directive looks in _includes for files that match. So {% include css/styles.css %} will look for that file path *within the _includes directory*. 

This is a little unexpected: for files *outside* the _includes directory, you need to have [YAML front matter](http://jekyllrb.com/docs/frontmatter/) which indicates to Jekyll that the file should be parsed with Liquid. For files that really don't have any front matter, you need to have at least the following at the start of the file:
```
---
---
```
**However**, within the _includes directory, files can reference other includes without being required to have frontmatter of their own. This isn't documented anywhere as far as I can tell, but it does work.

## Quirks
The `watch` processes don't seem to work exactly as expected for SASS -> CSS, for whatever reason. To force a rebuild I sometimes need to hit save on _sass/styles.scss, with the SublimeOnSaveBuild package active.

## Pushing Changes
Before pushing to GitHub, stop the Jekyll watch process and run `jekyll build`, which will give the correct relative paths to all links.


