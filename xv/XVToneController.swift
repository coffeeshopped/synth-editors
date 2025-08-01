
extension XV {
  
  enum Tone {
    
    enum Controller {
      
      static func wavesSetup(waveGroupOptions: [Int:String]) -> [PatchController.Effect] {
        [
          .setup([
            .configCtrl([.wave, .group], .opts(.init(opts: waveGroupOptions))),
          ]),
          .patchChange(paths: [[.wave, .group], [.wave, .group, .id]], { values in
            guard let waveGroupValue = values[[.wave, .group]],
              let waveGroupId = values[[.wave, .group, .id]] else { return [] }

            let options: [Int:String]
            switch waveGroupValue {
            case 0:
              options = XV.Voice.Tone.internalWaveOptions
            case 1:
              options = SRJVBoard.boards[waveGroupId]?.waveOptions ?? [:]
            default:
              options = SRXBoard.boards[waveGroupId]?.waveOptions ?? [:]
            }
            let numOptions = ParamOptions(opts: options.numPrefix(offset: 0))
            
            return [
              .setValue([.wave, .group], XV.Voice.Tone.value(forWaveGroup: waveGroupValue, id: waveGroupId)),
              .configCtrl([.wave, .number, .i(0)], .opts(numOptions)),
              .configCtrl([.wave, .number, .i(1)], .opts(numOptions)),
            ]
          }),
          .controlChange([.wave, .group]) { state, locals in
            let value = XV.Voice.Tone.waveGroup(forValue: locals[[.wave, .group]] ?? 0)
            return [
              [.wave, .group] : value.0,
              [.wave, .group, .id] : value.1
            ]
          },
          .basicPatchChange([.wave, .number, .i(0)]),
          .basicPatchChange([.wave, .number, .i(1)]),
          .basicControlChange([.wave, .number, .i(0)]),
          .basicControlChange([.wave, .number, .i(1)]),
          .dimsOn([.wave, .number, .i(0)], id: [.wave, .number, .i(0)]),
          .dimsOn([.wave, .number, .i(1)], id: [.wave, .number, .i(1)]),
        ]

      }
      
      static func envSetup(_ label: String, prefix: SynthPath, bipolar: Bool, levelSteps: Int, startLevel: Bool) -> (env: PatchController.PanelItem, effect: PatchController.Effect) {
        
        var maps: [PatchController.DisplayMap] = 4.map { .unit([.time, .i($0)]) } + levelSteps.map { .src([.level, .i($0)], { bipolar ? ($0 - 64) / 63 : $0 / 127 })}
        if startLevel {
          maps.append(.src([.level, .i(-1)], dest: [.start, .level], { bipolar ? ($0 - 64) / 63 : $0 / 127 }))
        }
        let env: PatchController.PanelItem = .display(.timeLevelEnv(pointCount: 4, sustain: 2, bipolar: bipolar), label, maps.map { $0.srcPrefix(prefix) }, id: [.env])

        let paths: [SynthPath] = 4.map { [.time, .i($0)] } + levelSteps.map { [.level, .i($0)] } + [(startLevel ? [.level, .i(-1)] : [])]
        let effect: PatchController.Effect = .editMenu([.env], paths: paths.map { prefix + $0 }, type: "XV5050RateLevelEnvelope", init: nil, rand: nil)
        
        return (env, effect)
      }
      
      static func fxSetup(path: SynthPath) -> [PatchController.Effect] {
        return [
          .setup([
            .configCtrl(path, .localPath(path)),
          ]),
          .patchChange(paths: [[.out, .assign], path, path + [.fx]], { values in
            guard let out = values[[.out, .assign]] else { return [] }
            let p: SynthPath = out == 0 ? path + [.fx] : path
            return [.setValue(path, values[p] ?? 0)]
          }),
          .controlChange(path, { state, locals in
            guard let out = state.prefixedValue([.out, .assign]) else { return nil }
            let p: SynthPath = out == 0 ? path + [.fx] : path
            return [p : locals[path] ?? 0]
          })
        ]
      }
      
      static let fxSetup = fxSetup(path: [.chorus]) + fxSetup(path: [.reverb])

    }
    
  }
  
}
