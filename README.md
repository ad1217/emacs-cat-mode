# Cat Mode &#128008; #

Doesn't work with emacs 26, and really wasn't terribly well written anyway. I wouldn't suggest using it anymore, although I hope to rewrite it someday.

## Description ##
Introducing cat-mode! Cat-mode is a mode that helps manage buffers by assigning them cats (short for catagories). It behaves a little bit like [persp-mode](https://github.com/Bad-ptr/persp-mode.el) and [perspective](https://github.com/nex3/perspective-el).

### Features ###
  * Every buffer has exactly one cat, which is inherited from the previous buffer (the one it was created in)
  * Every frame has a unique initial cat
    * This is really the useful part (for me, anyway), as it allows me to delete old groups of buffers from other projects that were open in separate buffers
  * Good ibuffer support
  * Probably not terribly well written!
  * Cats! (Does not include any actual cats)

### Future Features (If I, or someone else, ever gets around to them) ###
  * Being less poorly written
  * Setting cats by projectile projects
  * A function to run functions (such as switch-buffer) with only the buffers in a cat

### Differences From Persp-mode/Perspective ###
  * Cats are stored buffer-local, which has some advantages and disadvantages
      * Every buffer has exactly one cat
      * Cats are persistent across frames
  * Doesn't do window saving/restoring

## Usage ##
To install, just load the file. If using [quelpa](https://github.com/quelpa/quelpa), use this recipe: `cat-mode :fetcher github :repo "ad1217/emacs-cat-mode"`.
Load with `(cat-mode 1)`. Use `M-x customize-group RET cat-mode RET` to customize. Ibuffer usage is highly recommended. Turning on `ibuffer-auto-mode` is also recommended.

### Commands ###
  * `cat-set`: Sets the current buffer's cat
  * `cat-set-ibuffer`: Like cat-set, but operates on all marked buffers in ibuffer
  * `kill-cat`: Kills all buffers in cat
