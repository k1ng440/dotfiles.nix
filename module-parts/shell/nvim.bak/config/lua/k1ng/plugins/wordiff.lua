require('k1ng.lazy').add_specs({
  {
    'wordiff',
    after = function()
      require("wordiff").setup()
    end
  }
})
