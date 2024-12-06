let
  terra = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHyS/8OGr5KbM1PS7QO3qEwE1xN4JuEzI2SzkBWzks7c";
  ash = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJFqg4NlJu7u1pcCel3EZshVwUxIfwpsh2fxhaQlLAar";
  keys = [terra ash];
in {
  "floodSecrets.age".publicKeys = keys;
}
