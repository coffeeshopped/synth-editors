
extension JV880.Card {
  
  enum Controller {
    
    static func ctrlr() -> PatchController {
      .patch(color: 1, [
        .grid([[
          .select("Expansion Card", [.int]),
          .select("PCM Card", [.pcm]),
        ]]),
      ])
    }
  }
  
}
