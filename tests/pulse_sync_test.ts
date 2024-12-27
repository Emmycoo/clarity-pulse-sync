import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure that team member management works correctly",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const member1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('pulse-sync', 'add-team-member', [
        types.principal(member1.address)
      ], deployer.address)
    ]);
    
    block.receipts[0].result.expectOk();
  },
});

Clarinet.test({
  name: "Test availability setting functionality",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const member1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      // First add the member
      Tx.contractCall('pulse-sync', 'add-team-member', [
        types.principal(member1.address)
      ], deployer.address),
      
      // Then set their availability
      Tx.contractCall('pulse-sync', 'set-availability', [
        types.uint(1), // Monday
        types.uint(900), // 9:00
        types.uint(1700) // 17:00
      ], member1.address)
    ]);
    
    block.receipts.forEach(receipt => {
      receipt.result.expectOk();
    });
    
    // Verify availability
    let availabilityBlock = chain.mineBlock([
      Tx.contractCall('pulse-sync', 'get-member-availability', [
        types.principal(member1.address),
        types.uint(1)
      ], deployer.address)
    ]);
    
    const availability = availabilityBlock.receipts[0].result.expectSome();
    assertEquals(availability['start-time'], types.uint(900));
    assertEquals(availability['end-time'], types.uint(1700));
  },
});

Clarinet.test({
  name: "Test meeting scheduling and RSVP functionality",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const organizer = accounts.get('wallet_1')!;
    const attendee = accounts.get('wallet_2')!;
    
    let block = chain.mineBlock([
      // Add team members
      Tx.contractCall('pulse-sync', 'add-team-member', [
        types.principal(organizer.address)
      ], deployer.address),
      Tx.contractCall('pulse-sync', 'add-team-member', [
        types.principal(attendee.address)
      ], deployer.address),
      
      // Schedule meeting
      Tx.contractCall('pulse-sync', 'schedule-meeting', [
        types.ascii("Team Sync"),
        types.uint(1000),
        types.uint(1100),
        types.list([types.principal(attendee.address)])
      ], organizer.address),
      
      // RSVP to meeting
      Tx.contractCall('pulse-sync', 'rsvp-to-meeting', [
        types.uint(1),
        types.bool(true)
      ], attendee.address)
    ]);
    
    block.receipts.forEach(receipt => {
      receipt.result.expectOk();
    });
  },
});