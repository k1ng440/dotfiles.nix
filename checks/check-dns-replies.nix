{
  self,
  ...
}:
{
  name = "check-dns-replies";
  node.specialArgs.selfPkgs = self.packages;
  nodes.machine1 = _: { };
}
