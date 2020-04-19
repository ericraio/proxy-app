# frozen_string_literal: true

require 'spec_helper'
require 'constraint/system'

describe Constraint::System do
  describe '.matches?' do
    context 'when subdomain is missing' do
      let(:request) { double('request', subdomain: nil) }

      it 'returns false' do
        expect(Constraint::System.matches?(request)).to be false
      end
    end

    context 'when a subdomain is present' do
      context 'when the subdomain is set to `system`' do
        context 'when the request host matches the domain host`' do
          let(:request) { double('request', subdomain: 'system', host: Settings.host) }

          it 'returns true' do
            expect(Constraint::System.matches?(request)).to be true
          end
        end

        context 'when the request host does not match the domain host`' do
          let(:request) { double('request', subdomain: 'system', host: 'google.com') }

          it 'returns true' do
            expect(Constraint::System.matches?(request)).to be false
          end
        end
      end

      context 'when the subdomain is not system' do
        let(:request) { double('request', subdomain: 'cdn', host: Settings.host) }

        it 'returns true' do
          expect(Constraint::System.matches?(request)).to be false
        end
      end
    end
  end
end
