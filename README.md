# Chess

## Table of Contents

1. [Running the Game](#running-the-game)
2. [Game Features](#game-features)
3. [Gameplay Showcase](#gameplay-showcase)

## Running the Game

### Option 1: Remotely
To run remotely, remix this Replit app and click `Run` to begin playing!  
<div align="center">
    
[![Replit app](https://replit.com/badge?caption=Run%20on%20Replit)](https://replit.com/@j542yu/chess?v=1)

</div>

### Option 2: Locally

1. **Install Ruby**

    Follow the official installation guide [here](https://www.ruby-lang.org/en/documentation/installation/).

2. **Clone the Repository**:
   * [Fork](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo) this repository.
   * [Clone](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) your forked repo to your local machine.

3. **Navigate into the project directory:**

    ```bash
    ~$ cd chess
    ```

4. **Install dependencies** 
    * Option 1: Using Bundler

        ```bash
        ~$ bundle install
        ```

        *Gems included:* `rainbow`, `rubocop`, and `rspec`. Only `rainbow` is needed to run the game.

    * Option 2: Install `rainbow` directly in command line

        ```bash
        ~$ gem install rainbow -v 3.0.0
        ```

5. **Run the game:**

    ```bash
    ~$ ruby main.rb
    ```
## Game Features

* ### Game Modes
    Upon running the game, a game mode can be selected:
    * **Human vs. Human:** Two players take turns playing on the same machine.
    * **Human vs. Computer:** The player plays against the computer, which selects random legal moves.

* ### Full Piece Movement Capabilities
    * **Standard Moves:** Every piece moves according to traditional chess rules.
    * **Special Moves** are supported, including castling, en passant, and pawn promotion.

* ### Game Saving and Loading
    * Upon running the game, the player can **start a new game** or **load a saved game**.
    * After every move, the player can choose to **save the game progress** which can be loaded upon running the game again.

* ### Move and Check Validation
    * **Prevents Illegal Moves:** The game disallows any move that leaves the king in check.
    * **Checkmate Detection:** The game automatically ends when a player’s king is in checkmate and no escape is possible.
    > Note: The game does not support stalemate or resignation automatic endings, but the player is informed that `Ctrl-C` can be used to terminate the game at any moment.

## Gameplay Showcase
* Human VS Human game
  
    [![starting_human_vs_human_game.gif](https://s3.gifyu.com/images/bbbmX.gif)](https://gifyu.com/image/bbbmX)  

* Human VS Computer game
  
    [![starting_human_vs_computer_game.gif](https://s3.gifyu.com/images/bbMSg.gif)](https://gifyu.com/image/bbMSg)
  
* Opening saved games and using en passant to capture opponent pawn
  
    [![en_passant.gif](https://s3.gifyu.com/images/bbbme.gif)](https://gifyu.com/image/bbbme)

* Handling invalid player input
  
    [![invalid_input_handling.gif](https://s3.gifyu.com/images/bbbqS.gif)](https://gifyu.com/image/bbbqS)

* Castling (kingside and queenside)
  
    [![castling.gif](https://s3.gifyu.com/images/bbbq2.gif)](https://gifyu.com/image/bbbq2)

* Checkmate detection
  
  [![checkmate_game_end.gif](https://s3.gifyu.com/images/bbMd3.gif)](https://gifyu.com/image/bbMd3)
